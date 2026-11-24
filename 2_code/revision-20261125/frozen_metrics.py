import math
from statistics import NormalDist
import numpy as np

def expit(x):
    x=np.asarray(x,float);z=np.exp(-np.abs(x))
    return np.where(x>=0,1/(1+z),z/(1+z))

def ratio(a,b,positive_inf=False):
    a,b=np.broadcast_arrays(np.asarray(a,float),np.asarray(b,float))
    out=np.full(a.shape,np.nan)
    np.divide(a,b,out=out,where=b!=0)
    if positive_inf:out[(b==0)&(a>0)]=np.inf
    return out

def quantile_extended(values,q):
    """Type-7 extended-real quantile. Never silently discard +Inf RR draws."""
    a=np.sort(np.asarray(values,float));a=a[~np.isnan(a)]
    if not len(a):return np.nan
    h=(len(a)-1)*q;i=int(math.floor(h));j=int(math.ceil(h));f=h-i
    if i==j or f==0:return float(a[i])
    if a[i]==a[j]:return float(a[i])
    if np.isneginf(a[i]) and np.isposinf(a[j]):return np.nan
    if np.isinf(a[i]):return float(a[i])
    if np.isinf(a[j]):return float(a[j])
    return float(a[i]+f*(a[j]-a[i]))

def interval(values):
    x=np.asarray(values,float)
    return {'CI_Lower':quantile_extended(x,.025),'CI_Upper':quantile_extended(x,.975),
            'Valid_B':int(np.count_nonzero(~np.isnan(x))),'Finite_B':int(np.isfinite(x).sum()),
            'PositiveInf_B':int(np.isposinf(x).sum()),'NegativeInf_B':int(np.isneginf(x).sum()),
            'NA_B':int(np.isnan(x).sum()),'CI_Method':'paired_percentile_type7_including_infinity'}

def wilson(events,n,level=.95):
    if n<=0:return np.nan,np.nan
    z=NormalDist().inv_cdf(.5+level/2);p=events/n;den=1+z*z/n
    center=(p+z*z/(2*n))/den;half=z*math.sqrt(p*(1-p)/n+z*z/(4*n*n))/den
    return max(0.,center-half),min(1.,center+half)

def exact_auc_pair(y,p):
    y=np.asarray(y,int);p=np.asarray(p,float);pp=p[y==1];pn=p[y==0]
    if not len(pp) or not len(pn):return np.nan
    return float((np.sum(pp[:,None]>pn[None,:])+.5*np.sum(pp[:,None]==pn[None,:]))/(len(pp)*len(pn)))

def calibration_batch(y,p,weights,epsilon=1e-6,tol=1e-10,maxiter=100):
    """Vectorized diagnostic unpenalized MLE; coefficients on original logit.

    Complete/quasi separation and singular/single-class samples return NA.
    Numerical centering/scaling changes only the evaluation-regression algebra.
    """
    y=np.asarray(y,float);p=np.asarray(p,float);w=np.atleast_2d(weights).astype(float)
    b,n=w.shape;N=w.sum(1);ev=w@y;both=(ev>0)&(ev<N)&(N>0)
    pc=np.clip(p,epsilon,1-epsilon);x=np.log(pc)-np.log1p(-pc)
    citl=np.full(b,np.nan);intercept=np.full(b,np.nan);slope=np.full(b,np.nan)
    cs=np.where(N<=0,1,2).astype(np.int8);ss=cs.copy();iterations=np.zeros(b,np.int16)
    # Offset score is monotone, so deterministic bisection is globally stable.
    ix=np.flatnonzero(both)
    if len(ix):
        ww=w[ix];target=ev[ix];bound=np.max(np.abs(x))+np.log(np.maximum(N[ix],2))+5
        lo=-bound;hi=bound
        for _ in range(70):
            mid=(lo+hi)/2;score=np.sum(ww*expit(x[None,:]+mid[:,None]),1)-target
            hi=np.where(score>=0,mid,hi);lo=np.where(score<0,mid,lo)
        citl[ix]=(lo+hi)/2;cs[ix]=0
    if not len(ix):return {'CITL':citl,'Slope':slope,'Calibration_Free_Intercept':intercept,
                          'CITL_Status_Code':cs,'Slope_Status_Code':ss,'Slope_Iterations':iterations}
    # One-dimensional separation can be tested exactly from support order.
    support=w>0
    pos_min=np.min(np.where(support&(y[None,:]==1),x,np.inf),axis=1)
    pos_max=np.max(np.where(support&(y[None,:]==1),x,-np.inf),axis=1)
    neg_min=np.min(np.where(support&(y[None,:]==0),x,np.inf),axis=1)
    neg_max=np.max(np.where(support&(y[None,:]==0),x,-np.inf),axis=1)
    mu=ratio(w@x,N);var=ratio(w@(x*x),N)-mu*mu
    observed_range=np.maximum(pos_max,neg_max)-np.minimum(pos_min,neg_min)
    constant=both&((observed_range<=1e-12)|(var<=1e-24))
    sep=both&~constant&((pos_min>=neg_max)|(neg_min>=pos_max))
    ss[constant]=3;ss[sep]=4
    active=both&~constant&~sep
    global_mu=x.mean();global_sd=x.std()
    if global_sd<=1e-12:
        ss[both]=3
        return {'CITL':citl,'Slope':slope,'Calibration_Free_Intercept':intercept,
                'CITL_Status_Code':cs,'Slope_Status_Code':ss,'Slope_Iterations':iterations}
    z=(x-global_mu)/global_sd;z2=z*z
    b0=np.zeros(b);b1=np.zeros(b);b0[both]=np.log(ev[both]/(N[both]-ev[both]))
    ss[active]=6
    for iteration in range(1,maxiter+1):
        ii=np.flatnonzero(active)
        if not len(ii):break
        ww=w[ii];eta=b0[ii,None]+b1[ii,None]*z;prob=expit(eta)
        residual=ww*(y-prob);g0=residual.sum(1);g1=residual@z
        converged=np.maximum(np.abs(g0),np.abs(g1))/N[ii]<=tol
        done=ii[converged]
        if len(done):
            slope[done]=b1[done]/global_sd;intercept[done]=b0[done]-slope[done]*global_mu
            ss[done]=0;iterations[done]=iteration;active[done]=False
        ii=ii[~converged]
        if not len(ii):continue
        ww=w[ii];eta=b0[ii,None]+b1[ii,None]*z;prob=expit(eta)
        residual=ww*(y-prob);g0=residual.sum(1);g1=residual@z
        v=ww*prob*(1-prob);h00=v.sum(1);h01=v@z;h11=v@z2;det=h00*h11-h01*h01
        singular=(~np.isfinite(det))|(det<=np.maximum(1.,h00*h11)*1e-14)
        bad=ii[singular];ss[bad]=5;active[bad]=False;iterations[bad]=iteration
        good=~singular;ii=ii[good]
        if not len(ii):continue
        d0=(h11[good]*g0[good]-h01[good]*g1[good])/det[good]
        d1=(h00[good]*g1[good]-h01[good]*g0[good])/det[good]
        ww=w[ii];eta=b0[ii,None]+b1[ii,None]*z
        old=np.sum(ww*(np.logaddexp(0,eta)-y*eta),1)
        pending=np.ones(len(ii),bool)
        for half in range(40):
            jj=np.flatnonzero(pending)
            if not len(jj):break
            t0=b0[ii[jj]]+d0[jj]*(.5**half);t1=b1[ii[jj]]+d1[jj]*(.5**half)
            e=t0[:,None]+t1[:,None]*z
            new=np.sum(ww[jj]*(np.logaddexp(0,e)-y*e),1)
            ok=np.isfinite(new)&(new<=old[jj]+1e-12)
            accepted=jj[ok];b0[ii[accepted]]=t0[ok];b1[ii[accepted]]=t1[ok];pending[accepted]=False
        bad=ii[pending];ss[bad]=7;active[bad]=False;iterations[ii]=iteration
    return {'CITL':citl,'Slope':slope,'Calibration_Free_Intercept':intercept,
            'CITL_Status_Code':cs,'Slope_Status_Code':ss,'Slope_Iterations':iterations}

def weighted_metrics(y,p,weights,calibration=True,chunk=500):
    y=np.asarray(y,int);p=np.asarray(p,float);w=np.atleast_2d(weights).astype(float)
    if len(y)!=len(p) or w.shape[1]!=len(y):raise ValueError('WEIGHT_OR_PREDICTION_LENGTH_MISMATCH')
    if not np.isin(y,[0,1]).all() or not np.isfinite(p).all() or not ((p>=0)&(p<=1)).all():raise ValueError('INVALID_Y_OR_ORIGINAL_P')
    if not np.isfinite(w).all() or np.any(w<0):raise ValueError('INVALID_WEIGHTS')
    N=w.sum(1);P=w@y;Q=N-P;order=np.argsort(-p,kind='stable')
    starts=np.r_[0,np.flatnonzero(np.diff(p[order])!=0)+1]
    gp=np.add.reduceat(w[:,order]*y[order],starts,axis=1)
    gt=np.add.reduceat(w[:,order],starts,axis=1);gn=gt-gp
    cp=np.cumsum(gp,axis=1);cn=np.cumsum(gn,axis=1)
    numerator=np.sum(gp*(Q[:,None]-cn+.5*gn),axis=1)
    auc=ratio(numerator,P*Q)
    precision=np.divide(cp,cp+cn,out=np.zeros_like(cp),where=cp+cn>0)
    ap=ratio(np.sum(gp*precision,axis=1),P)
    result={'AUROC':auc,'AP':ap,'Brier':ratio(w@((y-p)**2),N),
            'Mean_Predicted_Risk':ratio(w@p,N),'Observed_Event_Rate':ratio(P,N),
            'O_E':ratio(P,w@p,positive_inf=True),'Weighted_N':N,'Weighted_Events':P}
    if calibration:
        blocks=[]
        for start in range(0,len(w),chunk):blocks.append(calibration_batch(y,p,w[start:start+chunk]))
        for key in blocks[0]:result[key]=np.concatenate([b[key] for b in blocks])
    return result

def assign_strata(probabilities,q1,q2):
    p=np.asarray(probabilities,float)
    if not 0<=q1<=q2<=1:raise ValueError('TRAIN_CUTOFF_VALUES_INVALID')
    return np.where(p<=q1,'Low',np.where(p<=q2,'Intermediate','High'))

def quantile_groups(p,k):
    p=np.asarray(p,float)
    edges=np.unique(np.quantile(p,np.arange(1,k)/k,method='linear'))
    group=np.searchsorted(edges,p,side='left')
    return group,edges

def risk_ratio_rd(low,high):
    low=np.asarray(low,float);high=np.asarray(high,float)
    rr=ratio(high,low,positive_inf=True);rd=high-low
    bad=np.isnan(low)|np.isnan(high);rr[bad]=np.nan;rd[bad]=np.nan
    return rr,rd
