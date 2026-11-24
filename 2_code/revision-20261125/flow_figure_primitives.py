from math import hypot
from xml.sax.saxutils import escape
from reportlab.lib.colors import HexColor
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas

REGULAR, BOLD = "ArialFigure", "ArialFigureBold"
BOX_COLORS = {
    "SOURCE": "source", "ELIGIBILITY": "source", "EXCLUDED": "excluded",
    "FINAL": "included", "DEVELOPMENT": "included", "VALIDATION": "included",
}

def count_text(count):
    return f"(n = {count})"

def composed_lines(label, font, size, width, explicit_breaks=()):
    """Respect the source line breaks, wrapping long phrases within the box."""
    words = label.split()
    breakpoints = [0, *explicit_breaks, len(words)]
    lines = []
    for start, stop in zip(breakpoints[:-1], breakpoints[1:]):
        line = ""
        for word in words[start:stop]:
            candidate = f"{line} {word}" if line else word
            if line and pdfmetrics.stringWidth(candidate, font, size) > width:
                lines.append(line)
                line = word
            else:
                line = candidate
        lines.append(line)
    assert all(pdfmetrics.stringWidth(line, font, size) <= width for line in lines)
    return lines

def render_vectors(output, style, nodes, reasons, font_dir):
    width, height = (style["canvas"][key] for key in ("width_pt", "height_pt"))
    colors, layout, font = (style[key] for key in ("colors", "layout", "font"))
    pdfmetrics.registerFont(TTFont(REGULAR, str(font_dir / font["regular_file"])))
    pdfmetrics.registerFont(TTFont(BOLD, str(font_dir / font["bold_file"])))
    page = canvas.Canvas(str(output / "Fig1.pdf"), pagesize=(width, height),
                         pageCompression=1, invariant=1)
    page.setTitle(style["figure_title"])
    page.setAuthor("HBV readmission study")
    page.setSubject("Author-confirmed participant flow and cohort allocation")
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}pt" height="{height}pt" '
        f'viewBox="0 0 {width} {height}">',
        f'<title>{escape(style["figure_title"])}</title>',
        f'<rect width="{width}" height="{height}" fill="{style["canvas"]["background"]}"/>',
    ]
    bounds = []
    segments = []

    def put(owner, x, y, label, size, bold=False, center=False):
        face = BOLD if bold else REGULAR
        text_width = pdfmetrics.stringWidth(label, face, size)
        left = x - text_width / 2 if center else x
        ascent, descent = pdfmetrics.getAscentDescent(face, size)
        right, top, bottom = left + text_width, y - ascent, y - descent
        box = layout[owner]
        assert box["x"] + 9 <= left <= right <= box["x"] + box["w"] - 9, label
        assert box["y"] + 6 <= top <= bottom <= box["y"] + box["h"] - 6, label
        page.setFont(face, size)
        page.setFillColor(HexColor(colors["text"]))
        (page.drawCentredString if center else page.drawString)(x, height - y, label)
        svg.append(
            f'<text x="{x:.8g}" y="{y:.8g}" font-family="{font["family"]}, sans-serif" '
            f'font-size="{size}" font-weight="{700 if bold else 400}" '
            f'text-anchor="{"middle" if center else "start"}" fill="{colors["text"]}">'
            f'{escape(label)}</text>'
        )
        bounds.append((label, left, top, right, bottom))

    for key, palette in BOX_COLORS.items():
        x, y, w, h = (layout[key][dimension] for dimension in ("x", "y", "w", "h"))
        fill, stroke = colors[palette + "_fill"], colors[palette + "_stroke"]
        line_width = style["border_width_pt"]
        page.setFillColor(HexColor(fill))
        page.setStrokeColor(HexColor(stroke))
        page.setLineWidth(line_width)
        page.rect(x, height - y - h, w, h, fill=1, stroke=1)
        svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" '
                   f'stroke="{stroke}" stroke-width="{line_width}"/>')

    line_width = style["arrow_width_pt"]
    page.setLineWidth(line_width)
    page.setStrokeColor(HexColor(colors["text"]))
    page.setFillColor(HexColor(colors["text"]))
    for edge in style["edges"]:
        points = edge["points"]
        path = page.beginPath()
        path.moveTo(points[0][0], height - points[0][1])
        for x, y in points[1:]:
            path.lineTo(x, height - y)
        page.drawPath(path)
        coords = " ".join(f"{x},{y}" for x, y in points)
        svg.append(f'<polyline points="{coords}" fill="none" stroke="{colors["text"]}" '
                   f'stroke-width="{line_width}"/>')
        segments.extend(zip(points[:-1], points[1:]))
        if edge["arrow"]:
            x, y = points[-1]
            x_prev, y_prev = points[-2]
            distance = hypot(x - x_prev, y - y_prev)
            dx, dy = (x - x_prev) / distance, (y - y_prev) / distance
            length, half = style["arrowhead_length_pt"], style["arrowhead_halfwidth_pt"]
            triangle = [(x, y), (x - length * dx - half * dy, y - length * dy + half * dx),
                        (x - length * dx + half * dy, y - length * dy - half * dx)]
            path = page.beginPath()
            path.moveTo(x, height - y)
            for x_corner, y_corner in triangle[1:]:
                path.lineTo(x_corner, height - y_corner)
            path.close()
            page.drawPath(path, fill=1, stroke=0)
            coords = " ".join(f"{x},{y}" for x, y in triangle)
            svg.append(f'<polygon points="{coords}" fill="{colors["text"]}"/>')

    body, heading, leading = (font[key] for key in ("body_pt", "heading_pt", "leading_pt"))
    pad = style["padding_pt"]
    ascent, descent = pdfmetrics.getAscentDescent(REGULAR, body)
    for key in ("SOURCE", "ELIGIBILITY", "FINAL", "DEVELOPMENT", "VALIDATION"):
        node, box = nodes[key], layout[key]
        lines = composed_lines(node["label"], REGULAR, body, box["w"] - 2 * pad,
                               style["label_break_after_word"].get(key, ()))
        if node["n"]:
            lines.append(count_text(node["n"]))
        x = box["x"] + box["w"] / 2
        start = box["y"] + (box["h"] - (len(lines) - 1) * leading + ascent + descent) / 2
        for index, line in enumerate(lines):
            put(key, x, start + index * leading, line, body, center=True)

    key = "EXCLUDED"
    node, box = nodes[key], layout[key]
    headers = composed_lines(node["label"], BOLD, heading, box["w"] - 2 * pad,
                             style["label_break_after_word"][key])
    headers.append(count_text(node["n"]))
    x, y = box["x"] + pad, box["y"] + pad + heading
    for line in headers:
        put(key, x, y, line, heading, bold=True)
        y += leading
    y += 7  # Original spacing after the exclusion header.
    indent = style["bullet_indent_pt"]
    line_counts = []
    for reason in reasons:
        lines = composed_lines(reason["label_en"], REGULAR, body, box["w"] - 2 * pad - indent,
                               style["reason_break_after_word"].get(reason["rule_id"], ()))
        # Keep the full count together on the final line of the original label.
        lines[-1] += " " + count_text(reason["n"])
        assert pdfmetrics.stringWidth(lines[-1], REGULAR, body) <= box["w"] - 2 * pad - indent
        put(key, x, y, "•", body)
        for line in lines:
            put(key, x + indent, y, line, body)
            y += font["reason_leading_pt"]
        y += style["reason_gap_pt"]
        line_counts.append(len(lines))

    for index, (label, left, top, right, bottom) in enumerate(bounds):
        for other, l2, t2, r2, b2 in bounds[index + 1:]:
            assert not (left < r2 and l2 < right and top < b2 and t2 < bottom), (label, other)
        for (x1, y1), (x2, y2) in segments:
            half = line_width / 2
            assert not (left < max(x1, x2) + half and min(x1, x2) - half < right
                        and top < max(y1, y2) + half and min(y1, y2) - half < bottom), label

    page.showPage()
    page.save()
    (output / "Fig1.svg").write_text("\n".join([*svg, "</svg>"]) + "\n", encoding="utf-8")
    return line_counts
