############################## INTRODUCTION

Hello and welcome to the Druid!

The Druid is many things:

   - A cross-platform build system
   - A bootable disc image with tools and utilities
   - A way to install FreeBSD
   - A way to install Linux
   - A way to distribute firmware updates to the field
   - A solution to a multitude of problems/frustrations
   - A solution to efficiency by automation and customization

Most notably, it's a framework intended to be used by many developers. A
framework for developing bootable disc images with an easy-to-use intuitive
interface.

As you will see in the below instructions, you will `Configure' the Druid once,
but be able to build many things from there. Read carefully below to learn
which options build what, as each sub-project may build something entirely
different with the Druid framework.


############################## Configuration

First, we need to configure Druid to recognize your build environment.

	$ ./configure

Then,...

############################## Build

NOTE: On FreeBSD, substitute "gmake" wherever "make" is used

To build the DruidBSD ISO:

	$ make druidbsd

	Creates: DruidBSD-X.Y.iso

To build the Diagnostic/Repair Tools ISO:

	$ make tools

	Creates: Druid_Tools-X.Y.iso

To build the All-In-One Druid ISO (containing all of the above):

	$ make

	Creates: Druid-X.Y.iso

To build the Kitchen-Sink Developer's Edition (which may contain preview
software such as FreeBSD-9.x):

	$ make dev

	Creates: Dev_Druid-X.Y.iso

############################## Cleanup

To clean up the source directory:

	$ make clean

This leaves your compiled ISO around. Only intermediary dependencies are
cleaned up.

To return the source directory to its original state:

	$ make distclean

This cleans up everything (including compiled ISOs). It is as if you have un-
packed a fresh source archive.


################################################################################
#
# $Header: /cvsroot/druidbsd/druidbsd/druidbsd/doc/BUILD,v 1.1.1.1 2010/09/15 20:36:04 devinteske Exp $
#
# $Copyright: 2010 Devin Teske. All rights reserved. $
#
# $Log: BUILD,v $
# Revision 1.1.1.1  2010/09/15 20:36:04  devinteske
# Initial import of project.
#
#
################################################################################
