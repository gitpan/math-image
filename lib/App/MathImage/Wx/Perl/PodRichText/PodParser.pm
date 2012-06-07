# Copyright 2012 Kevin Ryde

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


package App::MathImage::Wx::Perl::PodRichText::PodParser;
use strict;
use warnings;
use Carp;
use Pod::Escapes;
use Pod::ParseLink;
use base 'Pod::Parser';
our $VERSION = 100;

# uncomment this to run the ### lines
#use Smart::Comments;

# sub new {
#   my $class = shift;
#   ### PodRichText-Parser new() ...
#   my $self = $class->SUPER::new (@_);
#   return $self;
# }
#
# sub parse_from_string {
#   my ($self, $str) = @_;
#   require IO::String;
#   my $fh = IO::String->new ($str);
#   $self->parse_from_filehandle ($fh);
# }

my %accept_begin = ('' => 1, # when not in any begin
                    text => 1,
                    TEXT => 1);

# begin/end of whole document
sub begin_pod {
  my $self = shift;
  $self->SUPER::begin_pod(@_);

  $self->{'in_begin'} = '';
  $self->{'in_begin_stack'} = [];
  $self->{'indent'} = 0;

  my $textctrl = $self->{'textctrl'};
  my $attrs = $textctrl->GetBasicStyle;
  my $font = $attrs->GetFont;
  my $font_mm = $font->GetPointSize * (1/72 * 25.4);
  # 1.5 characters expressed in tenths of mm
  $self->{'indent_step'} = int($font_mm*10 * 1.5);
  ### $font_mm
  ### indent_step: $self->{'indent_step'}

  $textctrl->Clear;
  $textctrl->SetDefaultStyle ($textctrl->GetBasicStyle);
  $textctrl->BeginSuppressUndo;
  # .6 of a line, expressed in tenths of a mm
  $textctrl->BeginParagraphSpacing ($font_mm*10 * .2,  # before
                                    $font_mm*10 * .4); # after
  $textctrl->{'section_positions'} = {};
  $textctrl->{'heading_list'} = [];
  $self->{'freezer'} = Wx::WindowUpdateLocker->new($textctrl);
}
sub end_pod {
  my $self = shift;
  $self->SUPER::end_pod(@_);
  ### end_pod() ...

  delete $self->{'freezer'};
  my $textctrl = $self->{'textctrl'};
  $textctrl->EndSuppressUndo;
  $textctrl->EndParagraphSpacing;
  $textctrl->SetInsertionPoint(0);
  $textctrl->Thaw;
}

sub command {
  my ($self, $command, $text, $linenum, $paraobj) = @_;
  ### $command
  ### $text
  ### $paraobj

  if ($command eq 'begin') {
    push @{$self->{'in_begin_stack'}}, $self->{'in_begin'};
    if ($text =~ /(\w+)/) {
      $self->{'in_begin'} = $1;  # first word only
    } else {
      $self->{'in_begin'} = '';
    }
    return '';
  }
  if ($command eq 'end') {
    $self->{'in_begin'} = pop @{$self->{'in_begin_stack'}};
    if (! defined $self->{'in_begin'}) {
      $self->{'in_begin'} = '';  # if too many =end
    }
    ### pop to in_begin: $self->{'in_begin'}
    return '';
  }

  if (! $accept_begin{$self->{'in_begin'}}) {
    ### ignore: $self->{'in_begin'}
    return ''
  }

  my $textctrl = $self->{'textctrl'};
  $text =~ s/\s+$//;  # trailing whitespace

  if ($command eq 'over') {
    $self->{'indent'} += $self->{'indent_step'};
  } elsif ($command eq 'back') {
    $self->{'indent'} -= $self->{'indent_step'};

  } elsif ($command =~ /^head(\d*)/) {
    my $level = $1;
    $textctrl->BeginLeftIndent($self->{'indent'}
                               + ($level > 1 ? $self->{'indent_step'} / 2 : 0));
    $textctrl->BeginBold;
    my $start = $textctrl->GetInsertionPoint;
    $self->write_text($text,$linenum);
    $self->set_section_position
      ($textctrl->GetRange($start,$textctrl->GetInsertionPoint),
       $start);
    $textctrl->EndBold;
    $textctrl->Newline;
    $textctrl->EndLeftIndent;

  } elsif ($command =~ /^item/) {
    if ($text eq '*') {
      $self->{'bullet'} = 1;
    } elsif ($text =~ /^\d+$/) {
      $self->{'numbered_bullet'} = 1;
      $self->{'number'} = $text;
    } else {
      $textctrl->BeginLeftIndent($self->{'indent'});
      my $start = $textctrl->GetInsertionPoint;
      $self->write_text($text,$linenum);
      $self->set_item_position
        ($textctrl->GetRange($start,$textctrl->GetInsertionPoint),
         $start);
      $textctrl->Newline;
      $textctrl->EndLeftIndent;
    }

  } elsif ($command eq 'for') {

  } else {
    carp "Unknown command =$command";
    $textctrl->WriteText("=for $command $text");
    $textctrl->Newline;
  }
  return '';
}

sub textblock {
  my ($self, $text, $linenum, $paraobj) = @_;
  ### textblock() ...
  ### $text
  ### $linenum
  ### $paraobj

  if (! $accept_begin{$self->{'in_begin'}}) {
    ### ignore: $self->{'in_begin'}
    return ''
  }

  my $textctrl = $self->{'textctrl'};
  if (delete $self->{'bullet'}) {
    my $start = $textctrl->GetInsertionPoint;
    $textctrl->BeginStandardBullet("standard/circle",
                                   $self->{'indent'},
                                   $self->{'indent_step'});
    $self->write_text($text,$linenum);
    $self->set_item_position
      ($textctrl->GetRange($start,$textctrl->GetInsertionPoint),
       $start);
    $textctrl->Newline;
    $textctrl->EndStandardBullet;

  } elsif (delete $self->{'numbered_bullet'}) {
    my $start = $textctrl->GetInsertionPoint;
    $textctrl->BeginLeftIndent($self->{'indent'},
                               $self->{'indent_step'});
    $textctrl->WriteText($self->{'number'}.'. ');
    $self->write_text($text,$linenum);
    $self->set_item_position
      ($textctrl->GetRange($start,$textctrl->GetInsertionPoint),
       $start);
    $textctrl->Newline;
    $textctrl->EndLeftIndent;

    # Numbers bigger than the indent step are drawn overlapped by the text.
    # Use a plain hanging indent para for now.
    # $textctrl->BeginNumberedBullet($self->{'number'},
    #                                $self->{'indent'},
    #                                $self->{'indent_step'});
    # $self->write_text($text,$linenum);
    # $textctrl->Newline;
    # $textctrl->EndNumberedBullet;

  } else {
    $textctrl->BeginLeftIndent($self->{'indent'} + $self->{'indent_step'});
    $self->write_text($text,$linenum);
    $textctrl->Newline;
    $textctrl->EndLeftIndent;
  }
  return '';
}

sub write_text {
  my ($self, $text, $linenum) = @_;
  $text =~ s/\s+$//;  # trailing newlines and other whitespace
  $self->write_ptree ($self->parse_text({}, $text, $linenum));
}

sub write_ptree {
  my ($self, $ptree) = @_;
  ### write_ptree(): $ptree

  my $textctrl = $self->{'textctrl'};
  foreach my $child ($ptree->children) {
    if (! ref $child) { # text with no markup
      $child =~ s/[\r\n]/ /sg;  # flow newlines
      if ($self->{'in_S'}) {
        $child =~ tr/ /\xA0/;  # non-breaking space
      }
      $textctrl->WriteText($child);
      next;
    }
    my $cmd_name = $child->cmd_name;
    if ($cmd_name eq 'Z' || $cmd_name eq 'X') {

    } elsif ($cmd_name eq 'E') {
      my $e = $child->parse_tree->raw_text; # inside of E<>
      #### E: $e
      if (defined (my $char = Pod::Escapes::e2char($e))) {
        $textctrl->WriteText($char);
      } else {
        $textctrl->WriteText($child->raw_text); # whole E<foo>
      }

    } elsif ($cmd_name eq 'L') {
      my $raw_text = $child->parse_tree->raw_text;
      ### L: $raw_text
      if ($self->{'within_L'}) {
        $textctrl->WriteText($raw_text);
      } else {
        my ($text, $inferred, $name, $section, $type)
          = Pod::ParseLink::parselink ($raw_text);
        ### $text
        ### $inferred
        ### $name
        ### $section
        ### $type
        if ($type eq 'url') {
          $textctrl->BeginURL ($name);
          $textctrl->BeginUnderline;
          $self->write_text($inferred);
          $textctrl->EndUnderline;
          $textctrl->EndURL;
        } elsif ($type eq 'pod') {
          my $url = 'pod://';
          if (defined $name) { $url .= $name; }
          if (defined $section) { $url .= "#$section"; }
          $textctrl->BeginURL ($url);
          $textctrl->BeginUnderline;
          $self->write_text($inferred);
          $textctrl->EndUnderline;
          $textctrl->EndURL;
        } else {
          $textctrl->BeginUnderline;
          $self->write_text($inferred);
          $textctrl->EndUnderline;
        }
      }

    } elsif ($cmd_name eq 'B') {
      local $self->{'bold'} = 1;
      $textctrl->BeginBold;
      $self->write_ptree($child->parse_tree);
      $textctrl->EndBold;

    } elsif ($cmd_name eq 'I' || $cmd_name eq 'F') {
      $textctrl->BeginItalic;
      $self->write_ptree($child->parse_tree);
      $textctrl->EndItalic;

    } elsif ($cmd_name eq 'C') {
      my $font = ($self->{'code_font'} ||= do {
        my $basic_attrs = $textctrl->GetBasicStyle;
        my $basic_font = $basic_attrs->GetFont;
        ### basic font facename: $basic_font->GetFaceName
        my $font = Wx::Font->new ($basic_font);
        $font->SetFamily(Wx::wxFONTFAMILY_TELETYPE());
        my $facename = $font->GetFaceName;
        ### $facename
        $font
      });
      if ($self->{'bold'}) {
        $font->SetWeight (Wx::wxFONTWEIGHT_BOLD());
      }
      $textctrl->BeginFont($font);
      $self->write_ptree($child->parse_tree);
      $textctrl->EndFont;

      # $textctrl->BeginTextColour(Wx::wxRED());
      # $textctrl->EndTextColour;

      # my $attr = Wx::RichTextAttr->new;
      # my $facename = $font->GetFaceName;
      # ### $facename
      # $attr->SetFontFaceName($facename);
      # $attr->SetFlags (Wx::wxTEXT_ATTR_FONT_FACE());

      # my $start = $textctrl->GetInsertionPoint;
      # $self->write_ptree($child->parse_tree);
      # my $end = $textctrl->GetInsertionPoint;
      # $textctrl->SetStyle(Wx::RichTextRange->new($start,$end),$attr);

      # $textctrl->BeginStyle($attr);
      # #$textctrl->BeginFont($font);
      # # $textctrl->BeginTextColour(Wx::wxRED());
      # # $textctrl->EndTextColour;
      # #$textctrl->EndFont;
      # $textctrl->EndStyle;

    } elsif ($cmd_name eq 'S') {
      local $self->{'in_S'} = 1;
      $self->write_ptree($child->parse_tree);

    } else {
      # carp "Unknown markup $cmd_name<";
      $textctrl->WriteText("$cmd_name<");
      $self->write_ptree($child->parse_tree);
      $textctrl->WriteText(">");
    }
  }
}

sub verbatim {
  my ($self, $text, $linenum) = @_;

  if (! $accept_begin{$self->{'in_begin'}}) {
    ### ignore: $self->{'in_begin'}
    return ''
  }

  $text =~ s/\s+$//;    # trailing whitespace
  if ($text eq '') {
    ### collapse empty verbatim ...
    return '';
  }

  $text =~ tr/\n/\x1D/; # Wx::wxRichTextLineBreakChar()

  my $textctrl = $self->{'textctrl'};
  my $basic_attrs = $textctrl->GetBasicStyle;
  my $basic_font = $basic_attrs->GetFont;
  my $font = Wx::Font->new ($basic_font->GetPointSize,
                            Wx::wxFONTFAMILY_TELETYPE(),
                            0,
                            0);
  $textctrl->BeginLeftIndent($self->{'indent'} + $self->{'indent_step'});
  $textctrl->BeginRightIndent(-10000);

  $textctrl->BeginFont($font);
  $textctrl->WriteText($text);
  $textctrl->EndFont;
  $textctrl->Newline;

  # $textctrl->BeginTextColour(Wx::wxRED());
  # $textctrl->EndTextColour;

  $textctrl->EndRightIndent;
  $textctrl->EndLeftIndent;
  return '';

  # if (my @lines = split /\n/, $text) {
  #   $textctrl->WriteText(shift @lines);
  #   foreach my $line (@lines) {
  #     # $textctrl->LineBreak;
  #     $textctrl->WriteText(chr(29)); # # Wx::wxRichTextLineBreakChar()));
  #     $textctrl->WriteText($line);
  #   }
  # }
}

# set the position of $section to $pos
# if $pos is not given then default to the current insertion point
sub set_section_position {
  my ($self, $section, $pos) = @_;
  $section =~ s/\s+$//; # trailing whitespace
  push @{$self->{'heading_list'}}, $section;
  $self->{'section_positions'}->{$section} = $pos;
  $section = lc($section);
  if (! defined $self->{'section_positions'}->{$section}) {
    $self->{'section_positions'}->{$section} = $pos;
  }
}
sub set_item_position {
  my ($self, $item, $pos) = @_;
  $item =~ s/\s+$//; # trailing whitespace
  foreach my $name ($item,
                 ($item =~ /(\w+)/ ? $1 : ())) { # also just the first word
    $self->{'section_positions'}->{$name} = $pos;
    my $lname = lc($name);
    if (! defined $self->{'section_positions'}->{$lname}) {
      $self->{'section_positions'}->{$lname} = $pos;
    }
  }
}

1;
__END__
