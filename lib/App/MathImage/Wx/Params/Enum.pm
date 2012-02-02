# Copyright 2011, 2012 Kevin Ryde

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


package App::MathImage::Wx::Params::Enum;
use 5.004;
use strict;
use Wx;
use Locale::TextDomain 1.19 ('App-MathImage');

use base 'Wx::Choice';
our $VERSION = 92;


# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, $parent, $info) = @_;
  ### Params-Enum new(): "$parent"

  my $display = $info->{'display'};
  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),
                                 Wx::wxDefaultPosition(),
                                 Wx::wxDefaultSize(),
                                 $info->{'choices'});
  $self->SetValue ($info->{'default'});

    # my $name = $newval->{'name'};
    # my $display = ($newval->{'display'} || $name);
    # $self->set (enum_type => _pinfo_to_enum_type($newval),
    #             overflow_mnemonic =>
    #             Wx::Ex::MenuBits::mnemonic_escape($display));
    # if (! defined ($self->get('parameter-value'))) {
    #   $self->set (parameter_value => $newval->{'default'});
    # }
    # 
    # my $combobox = $self->get_child;
    # set_property_maybe ($combobox, # tearoff-title new in 2.10
    #                     tearoff_title => __('Math-Image:').' '.$display);

  # EVT_CHOICE ($self, 'OnChoiceSelected');
  return $self;
}

sub GetValue {
  my ($self) = @_;
  $self->GetStringSelection;
}
sub SetValue {
  my ($self, $newval) = @_;
  $self->SetStringSelection($newval);
}

# sub _pinfo_to_enum_type {
#   my ($pinfo) = @_;
#   my $key = $pinfo->{'share_key'} || $pinfo->{'name'};
#   my $enum_type = "App::MathImage::Wx::Params::Enum::$key";
#   if (! eval { Glib::Type->list_values ($enum_type); 1 }) {
#     my $choices = $pinfo->{'choices'} || [];
#     ### $choices
#     Glib::Type->register_enum ($enum_type, @$choices);
# 
#     if (my $choices_display = $pinfo->{'choices_display'}) {
#       no strict 'refs';
#       %{"${enum_type}::EnumBits_to_display"}
#         = map { $choices->[$_] => $pinfo->{'choices_display'}->[$_] }
#           0 .. $#$choices;
#     }
#   }
#   return $enum_type;
# }

1;
__END__
