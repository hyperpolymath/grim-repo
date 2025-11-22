// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Utility functions for GrimRepo
 * Pure functional helpers
 */

module String = {
  /**
   * Normalizes a file path to lowercase and removes trailing slashes
   */
  let normalizePath = (path: string): string =>
    path->Js.String2.toLowerCase->Js.String2.replaceByRe(%re("/\/+$/"), "")

  /**
   * Checks if a string starts with a prefix
   */
  let startsWith = (str: string, prefix: string): bool =>
    Js.String2.startsWith(str, prefix)

  /**
   * Checks if a string ends with a suffix
   */
  let endsWith = (str: string, suffix: string): bool =>
    Js.String2.endsWith(str, suffix)

  /**
   * Splits a string by a delimiter
   */
  let split = (str: string, delimiter: string): array<string> =>
    Js.String2.split(str, delimiter)

  /**
   * Trims whitespace from both ends
   */
  let trim = (str: string): string =>
    Js.String2.trim(str)

  /**
   * Converts string to uppercase
   */
  let toUpperCase = (str: string): string =>
    Js.String2.toUpperCase(str)

  /**
   * Replaces all occurrences of a pattern
   */
  let replaceAll = (str: string, pattern: Js.Re.t, replacement: string): string =>
    Js.String2.replaceByRe(str, pattern, replacement)
}

module Array = {
  /**
   * Checks if an array is empty
   */
  let isEmpty = (arr: array<'a>): bool =>
    Belt.Array.length(arr) == 0

  /**
   * Checks if an array is not empty
   */
  let isNotEmpty = (arr: array<'a>): bool =>
    Belt.Array.length(arr) > 0

  /**
   * Gets the first element of an array
   */
  let head = (arr: array<'a>): option<'a> =>
    Belt.Array.get(arr, 0)

  /**
   * Gets the last element of an array
   */
  let last = (arr: array<'a>): option<'a> =>
    Belt.Array.get(arr, Belt.Array.length(arr) - 1)

  /**
   * Sums an array of integers
   */
  let sum = (arr: array<int>): int =>
    Belt.Array.reduce(arr, 0, (acc, x) => acc + x)

  /**
   * Finds the maximum value in an array
   */
  let max = (arr: array<int>): option<int> =>
    if isEmpty(arr) {
      None
    } else {
      Some(Belt.Array.reduce(arr, Belt.Array.getExn(arr, 0), (acc, x) =>
        if x > acc { x } else { acc }
      ))
    }

  /**
   * Finds the minimum value in an array
   */
  let min = (arr: array<int>): option<int> =>
    if isEmpty(arr) {
      None
    } else {
      Some(Belt.Array.reduce(arr, Belt.Array.getExn(arr, 0), (acc, x) =>
        if x < acc { x } else { acc }
      ))
    }

  /**
   * Removes duplicates from an array
   */
  let unique = (arr: array<'a>): array<'a> =>
    Belt.Array.reduce(arr, [], (acc, item) =>
      if Belt.Array.some(acc, x => x == item) {
        acc
      } else {
        Belt.Array.concat(acc, [item])
      }
    )

  /**
   * Chunks an array into groups of size n
   */
  let chunk = (arr: array<'a>, size: int): array<array<'a>> => {
    let rec go = (remaining, acc) =>
      if Belt.Array.length(remaining) <= size {
        if Belt.Array.length(remaining) == 0 {
          acc
        } else {
          Belt.Array.concat(acc, [remaining])
        }
      } else {
        let chunk = Belt.Array.slice(remaining, ~offset=0, ~len=size)
        let rest = Belt.Array.sliceToEnd(remaining, size)
        go(rest, Belt.Array.concat(acc, [chunk]))
      }

    go(arr, [])
  }
}

module Math = {
  /**
   * Calculates percentage
   */
  let percentage = (part: int, whole: int): int =>
    if whole == 0 {
      0
    } else {
      Float.toInt(Float.fromInt(part) /. Float.fromInt(whole) *. 100.0)
    }

  /**
   * Clamps a value between min and max
   */
  let clamp = (value: int, min: int, max: int): int =>
    if value < min {
      min
    } else if value > max {
      max
    } else {
      value
    }

  /**
   * Rounds a float to nearest integer
   */
  let round = (value: float): int =>
    Float.toInt(value +. 0.5)
}

module Option = {
  /**
   * Gets value from option or returns default
   */
  let getWithDefault = (opt: option<'a>, default: 'a): 'a =>
    switch opt {
    | Some(value) => value
    | None => default
    }

  /**
   * Maps over option
   */
  let map = (opt: option<'a>, fn: 'a => 'b): option<'b> =>
    switch opt {
    | Some(value) => Some(fn(value))
    | None => None
    }

  /**
   * Flat maps over option
   */
  let flatMap = (opt: option<'a>, fn: 'a => option<'b>): option<'b> =>
    switch opt {
    | Some(value) => fn(value)
    | None => None
    }

  /**
   * Checks if option is Some
   */
  let isSome = (opt: option<'a>): bool =>
    switch opt {
    | Some(_) => true
    | None => false
    }

  /**
   * Checks if option is None
   */
  let isNone = (opt: option<'a>): bool =>
    switch opt {
    | Some(_) => false
    | None => true
    }
}
