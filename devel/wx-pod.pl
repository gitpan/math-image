#!/usr/bin/perl -w

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

use 5.004;
use strict;
use Wx;
use Wx::RichText;

# uncomment this to run the ### lines
use Devel::Comments;

use 5.004;
use strict;
use Wx;

# uncomment this to run the ### lines
use Smart::Comments;

my $str;

# {
#   my $app = Wx::SimpleApp->new;
#   my $frame = Wx::Frame->new(undef, Wx::wxID_ANY(), 'Pod');
#   require Wx::Perl::PodEditor;
#   my $editor = Wx::Perl::PodEditor->create( $frame, [500,220] );
#   $editor->set_pod ();
#   $frame->Show;
#   $app->MainLoop;
#   exit 0;
# }
# 
# {
#   my $app = Wx::SimpleApp->new;
#   my $frame = Wx::Frame->new(undef, Wx::wxID_ANY(), 'Pod');
# 
#   require App::MathImage::Wx::Perl::PodRichText;
#   my $textctrl = App::MathImage::Wx::Perl::PodRichText->new ($frame);
#   # $textctrl->goto_pod (string => $str);
#   # $textctrl->goto_pod (module => 'FindBin');
#   $textctrl->goto_pod (module => 'perlfunc');
#   #  $textctrl->goto_module (module => 'Math::PlanePath::SquareSpiral');
# 
#   $frame->SetSize (800, 800);
# 
#   $frame->Show;
#   $app->MainLoop;
#   exit 0;
# }
# 
# {
#   my $app = Wx::SimpleApp->new;
#   my $frame = Wx::Frame->new(undef, Wx::wxID_ANY(), 'Pod');
# 
#   my $textctrl = Wx::RichTextCtrl->new ($frame);
#   $textctrl->WriteText ('abc ' x 100);
#   $textctrl->Newline;
# 
#   $textctrl->BeginRightIndent(-100);
#   $textctrl->WriteText ('abc ' x 100);
#   $textctrl->Newline;
#   $textctrl->EndRightIndent;
# 
#   $frame->SetSize (800, 800);
#   $frame->Show;
#   $app->MainLoop;
#   exit 0;
# }

$str = <<'HERE';
=head1 NAME

Foo - bar

Foo2 - bar2

=head1 DESCRIPTION

X<Index entry>  blah
Verbatim fjsdk fksdj fjks fjksd fjksd.  Fjs dfjks djfk sdjkf sdkf sdf

    +----------------------------------------+
    |                                        |
    +----------------------------------------+

    and more
    verb

    atim
    atim2

C<code+-------+> C<bold> I<italic> F<file>

link L<Math::Symbolic> F<filename>

plain L<http://localhost/index.html>
disp L<display part|http://localhost/index.html>
S<non breaking space section>

C<code> B<bold> I<italic> E<65> E<48> E<gt> E<fdjk> B<I<bold+italic>>

I<B<italic+bold> italicagain>

C<I<code+italic> codeagain>

C<code I<+italic B<+bold> italicagain> codeagain>

C<B<code+bold> codeagain>

B<C<bold+code> boldagain>

I<italic I<italic+italic> italicagain>.

link L</mysection>
link L<Math::Symbolic>
link L<Math::NumSeq>

=over

=item 1

item heading of first

more text of first E<16384>

=item 2

item heading of second

more text of second

=item 456789

item heading of blah

more text of blah

=item 3

item heading of third

more text of third

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=item 5

heading

=back

=begin comment

begin comment

=end comment

=begin something

begin block

=end something

=begin text

begin text

more of begin text

=end text

=head2 mysection

=over 4

Indent level one

=over 4

Indent level two

=over 4

Indent level three

=back

=back

=back




Plain para.


Plain para.

=over

=item first item

text of first

=item second C<foo-E<gt>bar> item

text of second

=back

Plain para.

=over

=item *

text of b1

plain b1

=item *

text of b2

plain b2

=back

=for nothing

=over 4

Indent

=over 4

=item *

bullet

Indent more

=back

=back

Unindented

=cut
HERE

{
  my $app = Wx::SimpleApp->new;
  require App::MathImage::Wx::Perl::PodBrowser;
  my $browser = App::MathImage::Wx::Perl::PodBrowser->new ();
  $browser->SetTitle ('hello');
  $browser->Show;
  if (@ARGV) {
    $browser->goto_pod (guess => $ARGV[0]);
  } else {
    $browser->goto_pod (string => $str);
    #$browser->goto_pod (module => 'Math::PlanePath::PeanoCurve');
    # $browser->goto_pod (module => 'Math::Symbolic');
    # $browser->goto_pod (module => 'FindBin');
    # $browser->goto_pod (module => 'perlfunc');
  }
  $app->MainLoop;
  exit 0;
}
