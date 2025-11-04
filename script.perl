#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use PerlPlotSVG;

PerlPlotSVG::SetDimensions(800, 400);

my @funcs = (
    sub { my $x = shift; return sin($x); },
    sub { my $x = shift; return cos($x); },
    sub { my $x = shift; return 0.5 * $x; },
    sub { my $x = shift; return 0.1 * $x**2 - 2; },
);
PerlPlotSVG::AutoScaleCoordinateSystem(\@funcs, -10, 10, 0.1);
PerlPlotSVG::DrawAxesWithGrid(ticks => 10);

my @colors = ('red', 'green', 'blue', 'orange');
for my $i (0..$#funcs) {
    PerlPlotSVG::PlotFunction($funcs[$i], -10, 10, 0.1, $colors[$i]);
}

PerlPlotSVG::SaveSVG();
