# Tutorial:
# Analysis and Visualization of Large Complex Data Sets with Tessera<sup>TM</sup>

**Ryan Hafen, Stephen F Elston, and Amanda White**

## Background:

R is a powerful language for statistical analysis and visualization, with most of its power restricted to data of small or moderate size. Using Tessera, users readily visualize and analyze large complex data sets in a familiar R environment.

Developed over the past two years as part of the DARPA XDATA program, [Tessera](http://tessera.io) is an open source statistical computing environment. Tessera enables R users to perform deep analysis of large, complex data sets. Principal contributors to the project are statisticians and computer scientists at Purdue University and Pacific Northwest National Laboratory.

Tessera uses the Divide and Recombine (D&R) approach. In D&R, data is divided into meaningful subsets, embarrassingly parallel computations are performed on the subsets, and results are combined in a statistically valid manner. Using the R datadr package, Tessera provides a simple interface to distributed parallel back end computation environments such as Hadoop or Spark.  Tessera includes a visualization component, Trelliscope, which provides a D&R approach for detailed, flexible, and interactive visualization of large complex data.

## Tutorial overview:

R users will gain hands-on experience analyzing and visualizing data with Tessera. Using the famous ASA Airline data set, we will demonstrate what Tessera is and how to apply it. Attendees will develop a practical feel for using Tessera for statistical analysis and visualization.

The interactive tutorial examples are small enough to run on an attendee-provided laptop. The techniques learned can be quickly scaled up to a Tessera cluster for larger data sets.

## Detailed Outline

Total time 130 min + final exercise.

This tutorial provides attendees hands-on experience using Tessera. We will cover the following topics in this tutorial:

1. Introduction to Tessera and datadr

 + Installing the packages (10 min)
 + Back-end options (5 min)
 + Key value pairs and divide-recombine (15 min)
Overview
Conditioning variable
Random splits
Recombination
Example
**Exercise**
 + Distributed data structures (10 min)
ddo
ddf
**Exercise**
 + Data operations (10 min)
drLapply
drFilter
drJoin
drSample
drSubset
**Exercise**
 + Transformations (10 min)
Overview
Lazy evaluation and efficiency
**Exercise**
 + Filtering (10 min)
Overview
**Exercises**
 + MapReduce with d&r (10 min)
<br><br>
2. Introduction to Trelliscope
  + Installation and configuration options for Tessera (5 min)
  + Multi-pannel displays and conditioning (10 min)
Overview
Panel functions
Axis limit options
**Exercise**
  + The visualization database (10 min)
  + Cognostics and display organization (10 min)
What is a cognostic?
Why use a cognostic?
Creating cognosic functions
**Exercises**
<br><br>
3. Analysis of the taxi data set

  + Overview of the taxi data set (5 min)
  + Pulling it all together (10 min)
  + Exercises for participants

## Background Knowledge:

Attendees should have basic proficiency with R and RStudio.

## Requirements for Interactive Session:

Attendees should have a laptop with the following installed:

- R 3.X
- A recent version of RStudio
- An up-to-date web browser, Chrome/Safari/Firefox
- The [datadr package](https://github.com/tesseradata/datadr)
- The [trelliscope package](https://github.com/tesseradata/trelliscope)

## Potential Attendees:

This tutorial is intended for any R user who must analyze and understand large and complex data sets in a familiar environment.
