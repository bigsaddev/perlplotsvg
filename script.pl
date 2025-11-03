#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use PerlPlotSVG;

PerlPlotSVG::SetDimensions(800, 400);
PerlPlotSVG::DrawRect(50, 50, 50, 50, "red");
PerlPlotSVG::DrawCircle(50, 50, 25, "black");

PerlPlotSVG::SaveSVG();
