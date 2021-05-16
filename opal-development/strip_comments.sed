#! /bin/sed -nf
# This file was originally released into the public domain
# (see sed.sourceforge.net/grabbag). It is distributed under CC0-1.0 with Opal.
# Source: http://sed.sourceforge.net/grabbag/scripts/remccoms3.sed
#
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: Brian Hiles <brian_hiles@rocketmail.com>
# SPDX-FileCopyrightText: Paolo Bonzini <bonzini@gnu.org>
# SPDX-FileCopyrightText: 2021 ichthyosaurus

# Remove C and C++ comments, by Brian Hiles (brian_hiles@rocketmail.com)
 
# Sped up (and bugfixed to some extent) by Paolo Bonzini (bonzini@gnu.org)
# Works its way through the line, copying to hold space the text up to the
# first special character (/, ", ').  The original version went exactly a
# character at a time, hence the greater speed of this one.  But the concept
# and especially the trick of building the line in hold space are entirely
# merit of Brian.
 
:loop
 
# This line is sufficient to remove C++ comments!
# /^\/\// s,.*,,

# Edit by ichthyosaurus, 2021-05-14: keep single-line comments starting
# with //@. This can be used e.g. for license info comments that must be kept.
/^\/\/[^@]/ s,.*,,

/^$/{
  x
  p
  n
  b loop
}
/^"/{
  :double
  /^$/{
    x
    p
    n
    /^"/b break
    b double
  }
 
  H
  x
  s,\n\(.[^\"]*\).*,\1,
  x
  s,.[^\"]*,,
 
  /^"/b break
  /^\\/{
    H
    x
    s,\n\(.\).*,\1,
    x
    s/.//
  }
  b double
}
 
/^'/{
  :single
  /^$/{
    x
    p
    n
    /^'/b break
    b single
  }
  H
  x
  s,\n\(.[^\']*\).*,\1,
  x
  s,.[^\']*,,
 
  /^'/b break
  /^\\/{
    H
    x
    s,\n\(.\).*,\1,
    x
    s/.//
  }
  b single
}
 
/^\/\*/{
  s/.//
  :ccom
  s,^.[^*]*,,
  /^$/ n
  /^\*\//{
    s/..//
    b loop
  }
  b ccom
}
 
:break
H
x
s,\n\(.[^"'/]*\).*,\1,
x
s/.[^"'/]*//
b loop
