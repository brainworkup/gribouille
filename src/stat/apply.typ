// Dispatch table for stat transforms.
// Keeps render.typ free of per-stat knowledge.

#import "identity.typ" as identity-stat
#import "bin.typ" as bin-stat
#import "count.typ" as count-stat
#import "smooth.typ" as smooth-stat
#import "boxplot.typ" as boxplot-stat
#import "summary.typ" as summary-stat
#import "summary-bin.typ" as summary-bin-stat
#import "ecdf.typ" as ecdf-stat
#import "unique.typ" as unique-stat

#let apply-stat(name, data, mapping, params) = {
  if name == none or name == "identity" {
    (data: data, mapping: mapping)
  } else if name == "bin" {
    bin-stat.apply(data, mapping, params: params)
  } else if name == "count" {
    count-stat.apply(data, mapping, params: params)
  } else if name == "smooth" {
    smooth-stat.apply(data, mapping, params: params)
  } else if name == "boxplot" {
    boxplot-stat.apply(data, mapping, params: params)
  } else if name == "summary" {
    summary-stat.apply(data, mapping, params: params)
  } else if name == "summary_bin" {
    summary-bin-stat.apply(data, mapping, params: params)
  } else if name == "ecdf" {
    ecdf-stat.apply(data, mapping, params: params)
  } else if name == "unique" {
    unique-stat.apply(data, mapping, params: params)
  } else {
    (data: data, mapping: mapping)
  }
}
