#!/usr/bin/env perl
package PerlPlotSVG;

use strict;
use warnings;

# Canvas elements and size
my @canvas_svg;
my $canvas_width  = 600;
my $canvas_height = 400;

# Logical coordinate system
my ($x_min, $x_max, $y_min, $y_max) = (0, 10, 0, 10);

# Init / Config
sub SetDimensions {
  ($canvas_width, $canvas_height) = @_;
}

sub SetCoordinateSystem {
    ($x_min, $x_max, $y_min, $y_max) = @_;
}

# Helpers
sub _to_canvas_x { ($_[0]-$x_min) / ($x_max-$x_min) * $canvas_width; }
sub _to_canvas_y { $canvas_height - (($_[0]-$y_min)/($y_max-$y_min) * $canvas_height); }

sub _find_function_bounds {
    my ($func, $x_min_plot, $x_max_plot, $step) = @_;
    $step ||= 0.1;

    my ($y_min_f, $y_max_f);
    for (my $x = $x_min_plot; $x <= $x_max_plot; $x += $step) {
        my $y = eval { $func->($x) };
        next if $@ or !defined $y;

        $y_min_f = $y if !defined $y_min_f || $y < $y_min_f;
        $y_max_f = $y if !defined $y_max_f || $y > $y_max_f;
    }

    return ($y_min_f, $y_max_f);
}

sub AutoScaleCoordinateSystem {
    my ($funcs_ref, $x_min_plot, $x_max_plot, $step) = @_;
    $step ||= 0.1;

    my ($global_y_min, $global_y_max);
    foreach my $func (@$funcs_ref) {
        my ($y_min_f, $y_max_f) = _find_function_bounds($func, $x_min_plot, $x_max_plot, $step);
        $global_y_min = $y_min_f if !defined $global_y_min || $y_min_f < $global_y_min;
        $global_y_max = $y_max_f if !defined $global_y_max || $y_max_f > $global_y_max;
    }

    my $margin = ($global_y_max - $global_y_min)*0.05; # 5% margin
    SetCoordinateSystem($x_min_plot, $x_max_plot, $global_y_min-$margin, $global_y_max+$margin);
}

# Drawing Primitives
sub DrawRect {
  # Takes arguments, generates the matching SVG tag and pushes it onto the buffer
  my ($x, $y, $w, $h, $color) = @_;
  # TODO: Add default styles and or style arguments
  push @canvas_svg, qq{<rect x="$x" y="$y" width="$w" height="$h" fill="$color" />};
}

sub DrawCircle {
  my ($cx, $cy, $r, $color) = @_;
  push @canvas_svg, qq{<circle cx="$cx" cy="$cy" r="$r" fill="$color" />};
}

sub DrawText {
  my ($x, $y, $text, $font_size, $color) = @_;
  push @canvas_svg, qq{<text x="$x" y="$y" font-size="$font_size" fill="$color">$text</text>};
}

# Single function plotting

sub PlotFunction {
    my ($func, $x_min_plot, $x_max_plot, $step, $color) = @_;
    $step ||= 0.1; # Default step size
    $color ||= 'red'; # Default color

    my @points;
    for (my $x = $x_min_plot; $x <= $x_max_plot; $x += $step) {
        my $y = eval { $func->($x) };
        next if $@;
        push @points, sprintf("%.2f, %.2f", _to_canvas_x($x), _to_canvas_y($y));
    }
push @canvas_svg, qq{<polyline points="@{[join ' ', @points]}" fill="none" stroke="$color" stroke-width="2" />};
}

# Axes and Grid
sub DrawAxes {
    my ($color) = @_;
    $color ||= 'black';

    my $x0 = _to_canvas_x(0);
    my $y0 = _to_canvas_y(0);

    # X-Axis
    push @canvas_svg, qq{<line x1="0" y1="$y0" x2="$canvas_width" y2="$y0" stroke="$color" stroke-width="1" />};
    # Y-Axis
    push @canvas_svg, qq{<line x1="$x0" y1="0" x2="$x0" y2="$canvas_height" stroke="$color" stroke-width="1" />};
}

sub DrawAxesWithGrid {
    my (%opts) = @_;
    my $color_axes  = $opts{axes_color}  || 'black';
    my $color_grid  = $opts{grid_color}  || 'lightgray';
    my $ticks       = $opts{ticks}       || 10;
    my $label_color = $opts{label_color} || 'black';
    my $font_size   = $opts{font_size}   || 10;

    my $x_step = ($x_max - $x_min)/$ticks;
    my $y_step = ($y_max - $y_min)/$ticks;

    # Horizontal grid + Y labels
    for (my $y=$y_min; $y<=$y_max; $y+=$y_step) {
        my $cy = _to_canvas_y($y);
        push @canvas_svg, qq{<line x1="0" y1="$cy" x2="$canvas_width" y2="$cy" stroke="$color_grid" stroke-width="0.5" />};
        next if $y==0;
        push @canvas_svg, qq{<text x="@{[_to_canvas_x(0)+5]}" y="@{[$cy-2]}" font-size="$font_size" fill="$label_color"> @{[sprintf("%.1f",$y)]} </text>};
    }

    # Vertical grid + X labels
    for (my $x=$x_min; $x<=$x_max; $x+=$x_step) {
        my $cx = _to_canvas_x($x);
        push @canvas_svg, qq{<line x1="$cx" y1="0" x2="$cx" y2="$canvas_height" stroke="$color_grid" stroke-width="0.5" />};
        next if $x==0;
        push @canvas_svg, qq{<text x="@{[$cx+2]}" y="@{[_to_canvas_y(0)-2]}" font-size="$font_size" fill="$label_color"> @{[sprintf("%.1f",$x)]} </text>};
    }

    # Main axes
    my $x0 = _to_canvas_x(0);
    my $y0 = _to_canvas_y(0);
    push @canvas_svg, qq{<line x1="0" y1="$y0" x2="$canvas_width" y2="$y0" stroke="$color_axes" stroke-width="1" />};
    push @canvas_svg, qq{<line x1="$x0" y1="0" x2="$x0" y2="$canvas_height" stroke="$color_axes" stroke-width="1" />};
}

#######################
# Finalization / Output
sub RenderSVG {
  # using a fancier way, use this if shit breaks
  # my $elements = join "\n", @canvas_svg;

  my $svg = << "SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="$canvas_width" height="$canvas_height">
    @{[ join "\n    ", @canvas_svg ]}
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
