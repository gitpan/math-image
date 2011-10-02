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


package App::MathImage::Wx::Params::String;
use 5.004;
use strict;
use Carp;
use POSIX ();
use Wx;

use base qw(Wx::TextCtrl);
our $VERSION = 74;


# uncomment this to run the ### lines
#use Devel::Comments;

sub new {
  my ($class, $parent, $info) = @_;
  ### Params-String new(): "$parent"

    # my $display = ($newval->{'display'} || $newval->{'name'});
  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),       # id
                                 $info->{'default'}, # initial value
                                 Wx::wxDefaultPosition(),
                                 Wx::Size->new (10*($info->{'width'} || 5),
                                                -1),
                                 Wx::wxTE_PROCESS_ENTER());  # style

  Wx::Event::EVT_TEXT_ENTER ($self, $self, 'OnTextEnter');
  return $self;
}

sub SetParameterInfo {
  my ($self, $info) = @_;
  $self->{'parameter_info'} = $info;

    # unless ($entry) {
    #   my $entry_class = 'Wx::Entry';
    #   my $type_hint = ($newval->{'type_hint'} || '');
    #   if ($type_hint eq 'oeis_anum') {
    #     require App::MathImage::Wx::OeisEntry;
    #     $entry_class = 'App::MathImage::Wx::OeisEntry';
    #   }
    #   if ($type_hint eq 'fraction') {
    #     require App::MathImage::Wx::FractionEntry;
    #     $entry_class = 'App::MathImage::Wx::FractionEntry';
    #   }
    #   $entry = $entry_class->new;
    #   if (exists $self->{'parameter_value_set'}) {
    #     $entry->set (text => $self->{'parameter_value_set'});
    #     $self->{'parameter_value_set'} = 1;
    #   }
    #   Scalar::Util::weaken (my $weak_self = $self);
    #   $entry->signal_connect (activate => \&_do_entry_activate, \$weak_self);
    #   $entry->show;
    #   $self->add ($entry);
    # }
}

sub SetValue {
  my ($self, $value) = @_;
  if (! defined $value) { $value = ''; }
  $self->SUPER::SetValue ($value);
}

sub OnTextEnter {
  my ($self, $event) = @_;
  #   ### Params-String OnActivate()...
  #   my $self = $$ref_weak_self || return;
  #   ### parameter-value now: $self->get('parameter-value')
  #   $self->notify ('parameter-value');
}

1;
__END__
