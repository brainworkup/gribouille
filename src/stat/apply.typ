// Dispatch table for stat transforms.
// Keeps render.typ free of per-stat knowledge.

#import "identity.typ" as identity-stat
#import "bin.typ" as bin-stat
#import "bin2d.typ" as bin2d-stat
#import "bin-hex.typ" as bin-hex-stat
#import "bindot.typ" as bindot-stat
#import "count.typ" as count-stat
#import "sum.typ" as sum-stat
#import "smooth.typ" as smooth-stat
#import "boxplot.typ" as boxplot-stat
#import "summary.typ" as summary-stat
#import "summary-bin.typ" as summary-bin-stat
#import "summary-2d.typ" as summary-2d-stat
#import "ecdf.typ" as ecdf-stat
#import "unique.typ" as unique-stat
#import "qq.typ" as qq-stat
#import "qq-line.typ" as qq-line-stat
#import "function.typ" as function-stat
#import "ellipse.typ" as ellipse-stat
#import "quantile.typ" as quantile-stat
#import "../utils/bin.typ": panel-bin-grid
#import "../utils/bin2d.typ": panel-bin-grid-2d
#import "../utils/hex.typ": panel-hex-grid

#let _stat-constructors = (
  bin: bin-stat.stat-bin,
  bin_2d: bin2d-stat.stat-bin-2d,
  bin_hex: bin-hex-stat.stat-bin-hex,
  bindot: bindot-stat.stat-bindot,
  smooth: smooth-stat.stat-smooth,
  boxplot: boxplot-stat.stat-boxplot,
  summary: summary-stat.stat-summary,
  summary_bin: summary-bin-stat.stat-summary-bin,
  summary_2d: summary-2d-stat.stat-summary-2d,
  function: function-stat.stat-function,
  ellipse: ellipse-stat.stat-ellipse,
  quantile: quantile-stat.stat-quantile,
)

#let stat-default-params(name) = {
  let ctor = _stat-constructors.at(name, default: none)
  if ctor == none { (:) } else { ctor().at("params", default: (:)) }
}

// Run a stat's optional panel-level setup once, before per-group `apply()`,
// so any partition shared across groups (currently the bin grid for binning
// stats) is computed from the full data and reused. Stats not listed here
// return their input params unchanged.
#let _binning-stats = ("bin", "bindot", "summary_bin")
#let _binning-2d-stats = ("bin_2d", "summary_2d")
#let _binning-hex-stats = ("bin_hex",)

#let setup-stat(name, data, mapping, params) = {
  if _binning-stats.contains(name) {
    panel-bin-grid(data, mapping, params)
  } else if _binning-2d-stats.contains(name) {
    panel-bin-grid-2d(data, mapping, params)
  } else if _binning-hex-stats.contains(name) {
    panel-hex-grid(data, mapping, params)
  } else {
    params
  }
}

#let apply-stat(name, data, mapping, params) = {
  if name == none or name == "identity" {
    (data: data, mapping: mapping)
  } else if name == "bin" {
    bin-stat.apply(data, mapping, params: params)
  } else if name == "bin_2d" {
    bin2d-stat.apply(data, mapping, params: params)
  } else if name == "bin_hex" {
    bin-hex-stat.apply(data, mapping, params: params)
  } else if name == "bindot" {
    bindot-stat.apply(data, mapping, params: params)
  } else if name == "count" {
    count-stat.apply(data, mapping, params: params)
  } else if name == "sum" {
    sum-stat.apply(data, mapping, params: params)
  } else if name == "smooth" {
    smooth-stat.apply(data, mapping, params: params)
  } else if name == "boxplot" {
    boxplot-stat.apply(data, mapping, params: params)
  } else if name == "summary" {
    summary-stat.apply(data, mapping, params: params)
  } else if name == "summary_bin" {
    summary-bin-stat.apply(data, mapping, params: params)
  } else if name == "summary_2d" {
    summary-2d-stat.apply(data, mapping, params: params)
  } else if name == "ecdf" {
    ecdf-stat.apply(data, mapping, params: params)
  } else if name == "unique" {
    unique-stat.apply(data, mapping, params: params)
  } else if name == "qq" {
    qq-stat.apply(data, mapping, params: params)
  } else if name == "qq-line" {
    qq-line-stat.apply(data, mapping, params: params)
  } else if name == "function" {
    function-stat.apply(data, mapping, params: params)
  } else if name == "ellipse" {
    ellipse-stat.apply(data, mapping, params: params)
  } else if name == "quantile" {
    quantile-stat.apply(data, mapping, params: params)
  } else {
    (data: data, mapping: mapping)
  }
}
