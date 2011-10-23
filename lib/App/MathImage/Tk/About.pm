# Copyright 2011 Kevin Ryde

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


package App::MathImage::Tk::About;
use 5.008;
use strict;
use warnings;
use Tk;
use Locale::TextDomain 1.19 ('App-MathImage');

# uncomment this to run the ### lines
#use Devel::Comments;

use base 'Tk::Derived', 'Tk::Dialog';
Tk::Widget->Construct('AppMathImageTkAbout');

our $VERSION = 78;

sub Populate {
  my ($self, $args) = @_;
  ### Populate(): $args
  $self->SUPER::Populate($args);
  $self->configure (-title   => __('Math-Image: About'),
                    -bitmap  => 'info',
                    -text    => (__x('Math Image version {version}',
                                     version => $VERSION)
                                 . "\n\n"
                                 . __x('Running under Perl {perl_version} and Perl-Tk {perl_tk_version} (Tk version {tk_version})',
                                       perl_version => $],
                                       perl_tk_version => Tk->VERSION,
                                       tk_version => $Tk::version)),
                   );
  my $button = $self->Subwidget('B_OK');
  $button->configure (-command => sub { $self->destroy });
  $button->focus;
}

1;
__END__
