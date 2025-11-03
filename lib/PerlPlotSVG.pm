#!/usr/bin/env perl

package PerlPlotSVG;

use strict;
use warnings;

# Variable to hold canvas elements
my @canvas_svg;

# Define the canvas size as package variables
my $canvas_width  = 600;
my $canvas_height = 400;

# Init / Config
sub SetDimensions {
  ($canvas_width, $canvas_height) = @_;
}

# Drawing Functions
sub DrawRect {
  # Takes arguments, generates the matching SVG tag and pushes it onto the buffer
  my ($x, $y, $w, $h) = @_;
  # TODO: Add default styles and or style arguments
  push @canvas_svg, qq{<rect x="$x" y="$y" width="$w" height="$h" fill="black" />};
}

# Finalization / Output
sub RenderSVG {
  # using a fancier way, use this if shit breaks
  # my $elements = join "\n", @canvas_svg;

  my $svg = << "SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="$canvas_width" height="$canvas_height">
    @{[ join "\n", @canvas_svg ]}
</svg>
SVG

  @canvas_svg = ();
  return $svg;
}

# Calls RenderSVG and writes to file
sub SaveSVG {
  my $svg_content = RenderSVG();

  open my $fh, ">", "plot.svg" or die "Cannot open plot.svg: $!";
  print $fh $svg_content;
  close $fh;

  print "Generated plot.svg!\n";
}

1;
