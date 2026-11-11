#import "@preview/keisen:0.2.0": *

#display-table(
  sales,
  table-header(
    title: [Regional sales],
    subtitle: [Financial year 2025 to 2026],
  ),
  table-stub(rowname: "product", group: "region", label: [Product]),
  columns-label(
    units: [Units],
    revenue: [Revenue],
    margin: [Margin],
  ),
  table-spanner([Performance], ("revenue", "margin")),
  format-integer("units"),
  format-currency("revenue", currency: "EUR", decimals: 0),
  format-percent("margin", decimals: 1),
  substitute-missing(auto, replacement: [--]),
  summary-rows(
    functions: (Subtotal: aggregate-sum),
    columns: ("units", "revenue"),
  ),
  grand-summary-rows(
    functions: (Total: aggregate-sum),
    columns: ("units", "revenue"),
  ),
  table-style(
    style(text: (fill: rgb("#c8442f"), weight: "bold")),
    locations: cells-body(columns: "margin", rows: row => row.margin < 0.05),
  ),
  data-colour(
    ("#fbfbf8", "#2c5f82"),
    columns: "revenue",
  ),
  table-footnote(
    [Excludes intra-group sales.],
    locations: cells-column-labels("revenue"),
  ),
  table-source-note([Source: internal ledger, extracted 2026-04-01.]),
  theme: theme-booktabs(),
)


