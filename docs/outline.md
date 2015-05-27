# Tutorial:
# Analysis and Visualization of Large Complex Data Sets with Tessera<sup>TM</sup>

**Ryan P. Hafen, Stephen F. Elston, and Amanda M. White**

## Background:

R is a powerful language for statistical analysis and visualization, with most of its power restricted to data of small or moderate size. Using Tessera, users readily visualize and analyze large complex data sets in a familiar R environment.

Developed over the past two years as part of the DARPA XDATA program, [Tessera](http://tessera.io) is an open source statistical computing environment. Tessera enables R users to perform deep analysis of large, complex data sets. Principal contributors to the project are statisticians and computer scientists at Purdue University and Pacific Northwest National Laboratory.

Tessera uses the Divide and Recombine (D&R) approach. In D&R, data is divided into meaningful subsets, embarrassingly parallel computations are performed on the subsets, and results are combined in a statistically valid manner. Using the R datadr package, Tessera provides a simple interface to distributed parallel back end computation environments such as Hadoop or Spark.  Tessera includes a visualization component, Trelliscope, which provides a D&R approach for detailed, flexible, and interactive visualization of large complex data.

## Tutorial overview:

R users will gain hands-on experience analyzing and visualizing data with Tessera. Using the famous ASA Airline data set, we will demonstrate what Tessera is and how to apply it. Attendees will develop a practical feel for using Tessera for statistical analysis and visualization.

The interactive tutorial examples are small enough to run on an attendee-provided laptop. The techniques learned can be quickly scaled up to a Tessera cluster for larger data sets.

## Detailed Outline

Total time 145 min + final exercise.

This tutorial provides attendees hands-on experience using Tessera. We will cover the following topics in this tutorial:

1. Introduction to Tessera and datadr

 + Overview and goals (15 min)
 + Installing the packages (10 min)
 + Overview of taxi dataset used in examples (5 min)
 + Datadr data representation (10 min)
    - What are key value pairs
    - Introduce distributed data objects (ddo) and distributed data frames (ddf)
 + Data ingest (15 min)
    - Back end options: in-memory, local disk, HDFS, Spark (coming soon)
    - Demonstrate drRead.csv with example data
    - Show examples: drRread.table, converting data.frame in memory directly, drRead.csv/drRead.table with hdfsConn
    - **Exercise**: Participants use drRead.csv to load taxi data
 + Division (15 min)
    - Introduce divide statement
    - Show example with data
    - **Exercise**: Participants divide data on a different variable
    - Solution: show possible solutions
 + Transformation (15 min)
    - Overview
    - Lazy evaluation and efficiency
    - Show example with data
    - **Exercise**: Participants construct their own transformation function and apply it
 + Recombine (15 min)
    - Overview
    - Discuss different combine methods (combRbind vs combDdo vs combCollect)
    - Demonstrate recombine statement on data
    - **Exercise**: Participants try recombine on the transformed data they created above
 + Data operations (15 min)
    - drJoin
       - Show example in with data
       - Examine the different structure of the data that is returned (ddo vs ddf)
    - drFilter
       - Show example with data
    - drLapply
    - drSample
    - drSubset
    - **Exercise**: Participants choose one (or more) of these operations and construct a command using the example data
 + Division independent data operations (?)
    - drQuantile
    - drAggregate
 + Hadoop demo (5 min)
    - Demonstrate a few commands using Hadoop on an Amazon cluster
 
2. Introduction to Trelliscope
  + Multi-panel displays and conditioning (15 min)
    - Overview
    - Panel functions
    - Axis limit options
    - The visualization database 
    - **Exercise**: Participants will create their own panel function
  + Cognostics and display organization (10 min)
    - What is a cognostic?
    - Why use a cognostic?
    - Creating cognosic functions
    - **Exercise**: Participants will create their own cognostic

3. Challenge exercise using Taxi data

  + **TODO**: Construct a question/goal for the participants to use Tessera tools to answer

## Background Knowledge:

Attendees should have basic proficiency with R and RStudio.

## Requirements for Interactive Session:

Attendees should have a laptop with the following installed:

- R 3.1.X or higher
- A recent version of RStudio
- An up-to-date web browser, Chrome/Firefox
- The [datadr package](https://github.com/tesseradata/datadr)
- The [trelliscope package](https://github.com/tesseradata/trelliscope)
- **TODO**: Other R libraries needed for the exercises?

## Potential Attendees:

This tutorial is intended for any R user who must analyze and understand large and complex data sets in a familiar environment.
