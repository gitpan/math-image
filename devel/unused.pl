#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

__END__



    #     {
    #       require File::Temp;
    #       my $fh = File::Temp->new;
    #       binmode($fh);
    #       ### filename: $fh->filename
    #       {
    #         require GD;
    #         my $gd = GD::Image->new ($width, $height);
    #         $gd->alphaBlending(0);
    #         $gen->draw_GD ($gd);
    #         ### drawn
    #         print $fh $gd->png(0);
    #         ### pnged
    #         close $fh;
    #       }
    #       ### filesize: -s $fh->filename
    #       $pixmap = $self->{'pixmap'}
    #         = Gtk2::Gdk::Pixmap->new ($self->window, $width, $height, -1);
    #       my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ($fh->filename);
    #       $pixmap->draw_pixbuf ($self->style->black_gc, $pixbuf,
    #                             0, 0, # source x,y
    #                             0, 0, # dest x,y
    #                             $width, $height,
    #                             'normal', # dither
    #                             0, 0);    # dither x,y
    #     }

    #     {
    #       require File::Temp;
    #       my $fh = File::Temp->new;
    #       binmode($fh);
    #       ### filename: $fh->filename
    #       {
    #         my $image_class;
    #         $image_class = 'Image::Base::GD';
    #         $image_class = 'Image::Base::PNGwriter';
    #         eval "require $image_class" or die;
    #         my $image = $image_class->new
    #           (-width      => $width,
    #            -height     => $height);
    #         $gen->draw_Image ($image);
    #         ### drawn
    #         $image->save ($fh->filename);
    #         ### saved
    #         close $fh;
    #       }
    #       ### filesize: -s $fh->filename
    #       $pixmap = $self->{'pixmap'}
    #         = Gtk2::Gdk::Pixmap->new ($self->window, $width, $height, -1);
    #       my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ($fh->filename);
    #       $pixmap->draw_pixbuf ($self->style->black_gc, $pixbuf,
    #                             0, 0, # source x,y
    #                             0, 0, # dest x,y
    #                             $width, $height,
    #                             'normal', # dither
    #                             0, 0);    # dither x,y
    #     }



# sub name {
#   my ($class_or_self) = @_;
#   my $class = (ref $class_or_self || $class_or_self);
#   $class =~ s/.*:://;
#   return $class;
# }

# sub n_to_xy {
#   my ($self, $n) = @_;
#   my ($r, $theta) = $self->n_to_rt ($n)
#     or return;
#   return ($r * cos($theta),
#           $r * sin($theta));
# }
# sub n_to_rt {
#   my ($self, $n) = @_;
#   my ($x, $y) = $self->n_to_xy ($n)
#     or return;
#   return (Math::Libm::hypot ($x, $y),
#           atan2 ($y, $x));
# }


} elsif ($option_shape eq 'spiral-stretch') {
my (@x,@y);
my $x = 0;
my $y = 0;
my $w = $width;
my $h = $height;
for (;;) {
  if ($w == 0 || $h == 0) { last; }
  foreach (my $i = 0; $i <= $h-1; $i++) {
    push @x, $x; push @y, $y+$i;     # left
  }
  foreach (my $i = 1; $i <= $w-1; $i++) {
    push @x, $x+$i; push @y, $y+$h-1;    # bottom
  }
  if ($w >= 1) {
    foreach (my $i = $h-2; $i >= 0; $i--) {
      push @x, $x+$w-1; push @y, $y+$i;     # right, upwards
    }
  }
  if ($h >= 1) {
    foreach (my $i = $w-2; $i >= 1; $i--) {
      push @x, $x+$i; push @y, $y;    # top, leftwards
    }
  }
  $x++; $y++;
  $w -= 2; $h -= 2;
}
@x = reverse @x;
@y = reverse @y;
$xy_func = sub {
  my ($n) = @_;
  if ($n > @x) {
    return (-1,-1);
  } else {
    return ($x[$n], $y[$n]);
  }
};


use constant DEFAULT_MODEL => do {

  my @formats;
  if (Gtk2::Gdk::Pixbuf->can('get_formats')) { # get_formats() new in Gtk 2.2
    @formats =
      map { $_->{'name'} }
        grep {
          my $format = $_;
          my $name = $format->{'name'};
          ### consider: $format

          ($format->can('is_writable')
           # is_writable() new in Gtk 2.2, and not wrapped until Perl-Gtk 1.240
           ? $format->is_writable

           : Gtk2->check_version (2,4,0)
           # 2.2 or earlier, only png and jpeg writable
           ? ($name eq 'png' || $name eq 'jpeg')

           # 2.4 or later, assume the five writables of 2.20
           : ($name eq 'png' || $name eq 'jpeg'
              || $name eq 'tiff' || $name eq 'ico' || $name eq 'bmp'))

        } Gtk2::Gdk::Pixbuf->get_formats;

  } else {
    @formats = [ 'png', 'jpeg' ]; # Gtk 2.0 writables
  }
  ### @formats
  my %formats;
  @formats{@formats} = ();  # hash slice

  my $model = Gtk2::ListStore->new ('Glib::String', 'Glib::String');

  # explicit formats forcing their order in the list, then everything else
  foreach my $name ('png','jpeg','tiff',
                    'svg','xpm','pcx','pnm','tga','ico','bmp','xbm',
                    @formats) {
    exists $formats{$name} or next;
    delete $formats{$name};  # once only forced-order ones 'png'
    $model->set ($model->append,
                 0 => $name,
                 1 => Locale::Messages::dgettext('Gtk2-Ex-WidgetBits',
                                                 uc($name)));
  }
  $model
};


# fibonacci
# inaccurate past 40 bits
#       require Math::Fibonacci;
#       use constant PHI => (1 + sqrt(5)) / 2;
#       my $count = POSIX::ceil (log($n_max * sqrt(5)) / log(PHI));
#       @values = Math::Fibonacci::series ($count);
#
    return 
    my $p + ($q = $p);
    $
  my @values = (1, 1);
  for (;;) {
    my $n = $values[-1] + $values[-2];
    if ($n > $hi) {
      last;
    }
    push @values, $n;
  }
  ### fib: scalar(@values)
  ### to: $values[-1]
  shift @values;
  return @values;

# perrin
  for (;;) {
    my $n = $values[-2] + $values[-3];
    if ($n > $hi) {
      last;
    }
    push @values, $n;
  }
  return @values;


# odd
  return map {2*$_+1} int($lo/2) .. int (($hi-1) / 2);
  # lo==0, i=0, first=1
  # lo==1, i=0, first=1
  # hi==5, i=2, last=5
  # hi==6, i=2, last=5

# even
  # lo==0, i=0, first=0
  # lo==1, i=1, first=2
  # hi==5, i=2, last=4
  # hi==6, i=3, last=6
  return map {2*$_} int(($lo+1)/2) .. int($hi/2);

sub values_list_squares {
  my ($self, $lo, $hi) = @_;
  ### values_list_squares(): $lo, $hi
  return map {$_*$_} $lo .. int(sqrt($hi));
}


sub values_list_triangular {
  my ($self, $lo, $hi) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(0.03); # for Ti() round up
  return map {Math::TriangularNumbers::T($_)}
    Math::TriangularNumbers::Ti($lo) .. Ti_floor($hi);
}
sub Ti_floor {
  my ($n) = @_;
  return Math::TriangularNumbers::Ti($n)
    - (Math::TriangularNumbers::is_T($n) ? 0 : 1);
}
# cf @values = map {$_*$_ + $_} 1 .. int (sqrt($n_max - 0.25) - 0.5);
sub values_list_pronic {
  my ($self, $lo, $hi) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(0.03); # for Ti() round up
  return map {2*Math::TriangularNumbers::T($_)}
    Math::TriangularNumbers::Ti(POSIX::ceil($lo/2))
        .. Ti_floor(POSIX::floor($hi/2));
}


  my @values = do {
    ### $method
    if (defined (my $coderef = $self->can($method))) {
      $self->$coderef ($
    } else {
      croak "Unrecognised values: $self->{'values'}";
    }
  };


# bit slower than XS
#
# use constant::defer primes_arrayref => sub {
#   require Math::Prime::TiedArray;
#   tie my @primes, 'Math::Prime::TiedArray';
#   return \@primes;
# };

  #   my @ret;
  #   my $primes_arrayref = primes_arrayref();
  #   @ret = ($primes_arrayref->[int($hi/log($hi))]);
  #   @ret = ();
  #   for (my $i = 0; ; $i++) {
  #     my $p = $primes_arrayref->[$i];
  #     if ($p > $hi) { last; }
  #     if ($p >= $lo) {
  #       push @ret, $p;
  #     }
  #   }
  #   return @ret;


# padovan  
  my @values = (1,1,1);
  for (;;) {
    my $n = $values[-2] + $values[-3];
    if ($n > $hi) {
      last;
    }
    push @values, $n;
  }
  return @values;



    if ( eq 'ulam') {
      $path_class = 'Math::PlanePath::SquareSpiral';
    } elsif ($self->{'path'} eq 'sacks_spiral') {
      $path_class = 'Math::PlanePath::SacksSpiral';
    } elsif ($self->{'path'} eq 'vogel_spiral') {
      $path_class = 'Math::PlanePath::VogelFloret';
    } elsif ($self->{'path'} eq 'diamond_spiral') {
      $path_class = 'Math::PlanePath::DiamondSpiral';
    } elsif ($self->{'path'} eq 'across') {
      $path_class = 'Math::PlanePath::Rows';
      $x_origin = $y_origin = $offset;
      $invert = 1;
    } elsif ($self->{'path'} eq 'down') {
      $path_class = 'Math::PlanePath::Down';
      $x_origin = $y_origin = $offset;
      $invert = 1;
    } elsif ($self->{'path'} eq 'pyramid_rows') {
      $path_class = 'Math::PlanePath::PyramidRows';
      $y_origin = $offset;
      $invert = 1;
    } elsif ($self->{'path'} eq 'corner') {
      $path_class = 'Math::PlanePath::Corner';
      $x_origin = $y_origin = $offset;
      $invert = 1;
    } elsif ($self->{'path'} eq 'diagonals') {
      $path_class = 'Math::PlanePath::Diagonals';
      $x_origin = $y_origin = $offset;
      $invert = 1;
    } else {
      croak "Unrecognised shape: $self->{'path'}";
    }


  my $values = $self->values_arrayref;
  ### $values

sub values_arrayref {
  my ($self) = @_;
  ### values_arrayref()
  return ($self->{'values_arrayref'} ||= do {
    my $pathobj = $self->path_object;
    my $coord = $self->{'coord'};
    ### generate from pathobj: $pathobj

    my $scale = $self->{'scale'};
    ### $scale
    my ($x1, $y1) = $coord->untransform (-$scale, -$scale);
    my ($x2, $y2) = $coord->untransform ($self->{'width'} + $scale,
                                         $self->{'height'} + $scale);
    ### limits around:
    ### $x1
    ### $x2
    ### $y1
    ### $y2
    my ($n_lo, $n_hi) =$pathobj->rect_to_n_range ($x1,$y1, $x2,$y2);
    ### $n_lo
    ### $n_hi

    if ($self->{'verbose'}) {
      print "n_hi  $n_hi\n";
    }
    if ($self->{'squeeze_odd'}) {
      $n_hi = 2 * $n_hi + 1;
    }

    my @values = do {
      my $method = "values_make_$self->{'values'}";
      ### $method
      if (defined (my $coderef = $self->can($method))) {
        $self->$coderef ($n_lo, $n_hi)
      } else {
        croak "Unrecognised values: $self->{'values'}";
      }
    };
    #    ### @values

    #           if ($self->{'squeeze_odd'}) {
    #             shift @values;
    #             foreach (@values) { $_ = ($_ - 1) / 2 }
    #           }
    if ($self->{'verbose'}) {
      print "values count ", scalar(@values),"\n";
    }
    \@values
  });
}


  my $theta = atan2($y,$x) / (2 * pi()); # 0 to 1
  my $slo = POSIX::floor (hypot($x,$y) - $theta);
  my $found_d = 0.5;
  my @found_n;
  foreach my $s ($slo, $slo+1) {
    my $nf = POSIX::floor ($s*$s + $theta * (2*$s + 1));
    foreach my $n ($nf, $nf+1) {
      if (my ($nx, $ny) = $self->n_to_xy($n)) {
        ### hypot: hypot($nx-$x, $ny-$y)
        my $d = hypot($nx-$x,$ny-$y);
        if ($d <= $found_d) {
          @found_n = ($n);
          $found_d = $d;
        }
      }
    }
  }

# sub _do_map {
#   my ($self) = @_;
#   ### _do_map()
#   shift->signal_chain_from_overridden (@_);
#   ### mapped now: $self->mapped
# 
# #   $self->{'draw'}->realize;
# #   _fullscreen_windows ($self);
# }
# sub _fullscreen_windows {
#   my ($self) = @_;
#   ### _fullscreen_windows()
#   my $fullscreen = $self->{'fullscreen'};
#   if (my $win = $self->{'draw'}->window) { # $self->window) {
#     if ($fullscreen) {
#       ### win fullscreen
#       $win->fullscreen;
#     } else {
#       ### win unfullscreen
#       $win->unfullscreen;
#     }
#   }
# #   if ($self->{'draw'}->window) {
# #     $self->{'draw'}->window->raise;
# #   }
# }

      if (Glib::Ex::ConnectProperties->VERSION >= 8) {
      } else {
        $entry->signal_connect (activate => sub {
                                  my ($entry) = @_;
                                  my $self = $entry->get_ancestor(__PACKAGE__);
                                  my $draw = $self->{'draw'};
                                  $draw->set (expression => $entry->get_text);
                                });
        $draw->signal_connect ('notify::expression' => \&_do_notify_expression);
        _do_notify_expression ($draw);  # initial value
      }
sub _do_notify_expression {
  my ($draw) = @_;
  ### Entry draw notify-expression: $draw->get('expression')
  my $self = $draw->get_ancestor(__PACKAGE__);
  my $entry = $self->{'expression_entry'};
  $entry->set_text ($draw->get('expression'));
}

