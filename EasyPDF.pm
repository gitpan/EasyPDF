#!/usr/bin/perl -wT

use strict;
package PDF::EasyPDF;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(inch mm);
our $VERSION = 0.02;

my $fonts = {"Times-Roman" => "TIM",
             "Times-Bold" => "TIMB",
             "Times-Italic" => "TIMI",
             "Times-BoldItalic" => "TIMBI",
             "Helvetica" => "HEL",
             "Helvetica-Bold" => "HELB",
             "Helvetica-Oblique" => "HELO",
             "Helvetica-BoldOblique" => "HELBO",
             "Courier" => "COU",
             "Courier-Bold" => "COUB",
             "Courier-Oblique" => "COUO",
             "Courier-BoldOblique" =>"COUBO",
             "Symbol" => "SYM",
             "ZapfDingbats" => "ZAP"};

my $standard_objects = <<STANDARD_OBJECTS;
1 0 obj
<< /Type /Catalog
   /Outlines 2 0 R
   /Pages 3 0 R
   >>
   endobj

2 0 obj
<< /Type Outlines
   /Count 0
   >>
   endobj

3 0 obj
<< /Type /Pages
   /Kids [4 0 R]
   /Count 1
   >>
   endobj

4 0 obj
<< /Type /Page
   /Parent 3 0 R
   /MediaBox [0 0 !!X!! !!Y!!]
   /Contents 20 0 R
   /Resources << /ProcSet 5 0 R
                 /Font << /TIM 6 0 R
                          /TIMB 7 0 R
                          /TIMI 8 0 R
                          /TIMBI 9 0 R
                          /HEL 10 0 R
                          /HELB 11 0 R
                          /HELO 12 0 R
                          /HELBO 13 0 R
                          /COU 14 0 R
                          /COUB 15 0 R
                          /COUO 16 0 R
                          /COUBO 17 0 R
                          /SYM 18 0 R
                          /ZAP 19 0 R
                          >>
              >>
   >>
   endobj

5 0 obj
   [/PDF /Text]
   endobj

6 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /TIM
   /BaseFont /Times-Roman
   /Encoding /MacRomanEncoding
   >>
   endobj

7 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /TIMB
   /BaseFont /Times-Bold
   /Encoding /MacRomanEncoding
   >>
   endobj

8 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /TIMI
   /BaseFont /Times-Italic
   /Encoding /MacRomanEncoding
   >>
   endobj

9 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /TIMBI
   /BaseFont /Times-BoldItalic
   /Encoding /MacRomanEncoding
   >>
   endobj

10 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /HEL
   /BaseFont /Helvetica
   /Encoding /MacRomanEncoding
   >>
   endobj

11 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /HELB
   /BaseFont /Helvetica-Bold
   /Encoding /MacRomanEncoding
   >>
   endobj

12 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /HELO
   /BaseFont /Helvetica-Oblique
   /Encoding /MacRomanEncoding
   >>
   endobj

13 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /HELBO
   /BaseFont /Helvetica-BoldOblique
   /Encoding /MacRomanEncoding
   >>
   endobj

14 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /COU
   /BaseFont /Courier
   /Encoding /MacRomanEncoding
   >>
   endobj

15 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /COUB
   /BaseFont /Courier-Bold
   /Encoding /MacRomanEncoding
   >>
   endobj

16 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /COUO
   /BaseFont /Courier-Oblique
   /Encoding /MacRomanEncoding
   >>
   endobj

17 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /COUBO
   /BaseFont /Courier-BoldOblique
   /Encoding /MacRomanEncoding
   >>
   endobj

18 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /SYM
   /BaseFont /Symbol
   /Encoding /MacRomanEncoding
   >>
   endobj

19 0 obj
<< /Type /Font
   /Subtype /Type1
   /Name /ZAP
   /BaseFont /ZapfDingbats
   /Encoding /MacRomanEncoding
   >>
   endobj

STANDARD_OBJECTS

my $content_object = <<CONTENT_OBJECT;
20 0 obj
<< /Length !!LENGTH!! >>
stream
!!STREAM!!endstream
endobj
CONTENT_OBJECT

sub new
{my $type = shift;
 my $hash = shift;
 my $self={};
 my @args = ('file','x','y');
 foreach my $arg (@args)
    {$self->{$arg} = $hash->{$arg}};
 $self->{stream} = "";
 $self->{font_name} = $fonts->{Courier};
 $self->{font_size} = 10;
 bless($self,$type);
 return $self};

sub close
{my $self = shift;
 my @offsets = ();
 my $out="%PDF-1.4\n";
 foreach my $ob (split /\n\n+/,$standard_objects . $self->content_object)
    {if
      ($ob =~/!!LENGTH!!/)
      {$ob=~/stream\n(.*)endstream/s;
       my $length=length($1);
       $ob=~s/!!LENGTH!!/$length/e};
     $ob=~s/!!X!!/int($self->{x}+0.5)/e;
     $ob=~s/!!Y!!/int($self->{y}+0.5)/e;
     push @offsets,length($out);
     $out .= "$ob\n\n"};
 my $xrefoffset = length($out);
 $out .= sprintf "xref\n0 %i\n0000000000 65535 f \n",$#offsets+2;
 foreach (@offsets)
    {$out .= sprintf "%10.10i 00000 n \n",$_}
 $out .= sprintf "\n\ntrailer\n<< /Size %i\n /Root 1 0 R\n>>\nstartxref\n$xrefoffset\n%%%%EOF",$#offsets+2;
 open (EASYPDF,">$self->{file}") or die "EasyPDF could not write PDF file '$self->{file}' : $!";
 print EASYPDF $out;
 close EASYPDF}

sub content_object
{my $self = shift;
 my $ret=$content_object;
 $ret =~s/!!STREAM!!/$self->{stream}/s;
 return $ret}

sub inch
{my $inches = shift;
 return $inches * 72}

sub mm
{my $mm = shift;
 return ($mm/25.4) * 72}

sub Fonts
{return sort keys %{$fonts}}

sub setStrokeColor
{my $self = shift;
 my ($r,$g,$b) = rrggbb(shift);
 $self->{stream} .= "$r $g $b RG\n"}

sub setFillColor
{my $self = shift;
 my ($r,$g,$b) = rrggbb(shift);
 $self->{stream} .= "$r $g $b rg\n"}

sub rrggbb
{my $hexstring = shift;
 $hexstring =~/([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])/i;
 return (hex($1)/255,hex($2)/255,hex($3)/255)}

sub setStrokeWidth
{my $self = shift;
 my $w = shift;
 $self->{stream} .= "$w w\n"}

sub setFontFamily
{my $self = shift;
 my $font = shift;
 die "Unknown font '$font'" unless defined $fonts->{$font};
 $self->{font_name} = $fonts->{$font}}

sub setFontSize
{my $self = shift;
 my $size = shift;
 $size+=0;
 die "Bad font size '$size'" unless $size > 0;
 $self->{font_size} = $size}

sub setDash
{my $self = shift;
 if
    (defined $_[1])
    {$self->{stream}.= "[ ";
     while
        (@_)
        {$self->{stream}.= shift(@_) . " "};
     $self->{stream} .= "] 0 d\n"}
    else
    {$self->{stream} .= "[] 0 d\n"}} 

sub setCap
{my $self = shift;
 my $captype = shift;
 if
    (lc($captype) eq 'round')
    {$self->{stream}.= "1 J\n"}
    elsif
    ((lc($captype) eq 'square') or (lc($captype) eq 'projecting'))
    {$self->{stream} .= "2 J\n"}
    else
    {$self->{stream} .= "0 J\n"}}

sub setJoin
{my $self = shift;
 my $captype = shift;
 if
    (lc($captype) eq 'round')
    {$self->{stream}.= "1 j\n"}
    elsif
    (lc($captype) eq 'bevel')
    {$self->{stream} .= "2 j\n"}
    else
    {$self->{stream} .= "0 j\n"}}

sub Text
{my $self = shift;
 my ($x,$y,$text) = @_;
 $self->{stream} .="BT\n/$self->{font_name} $self->{font_size} Tf\n$x $y Td\n($text) Tj\nET\n"}

sub Lines
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n";
 while
   (@_)
   {my $nextx = shift(@_);
    my $nexty = shift(@_);
    $self->{stream} .= "$nextx $nexty l\n"};
 $self->{stream} .= "S\n"}

sub Polygon
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n";
 while
   (@_)
   {my $nextx = shift(@_);
    my $nexty = shift(@_);
    $self->{stream} .= "$nextx $nexty l\n"};
 $self->{stream} .= "h\nS\n"}

sub FilledPolygon
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n";
 while
   (@_)
   {my $nextx = shift(@_);
    my $nexty = shift(@_);
    $self->{stream} .= "$nextx $nexty l\n"};
 $self->{stream} .= "h\nf\n"}

sub Curve
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nS\n"}

sub FilledCurve
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nh\nf\n"}

sub ClosedCurve
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nh\nS\n"}

sub CurveStart
{my $self = shift;
 my $startx = shift;
 my $starty = shift;
 $self->{stream} .= "$startx $starty m\n$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\n"}

sub CurveMiddle
{my $self = shift;
 $self->{stream} .= "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\n"}

sub CurveEnd
{my $self = shift;
 $self->{stream} .= "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nS\n"}

sub FilledCurveEnd
{my $self = shift;
 $self->{stream} .= "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nh\nf\n"}

sub ClosedCurveEnd
{my $self = shift;
 $self->{stream} .= "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] c\nh\nS\n"}

sub Rectangle
{my $self = shift;
 my ($x,$y,$dx,$dy) = @_;
 $self->{stream} .="$x $y $dx $dy re\nS\n"}

sub FilledRectangle
{my $self = shift;
 my ($x,$y,$dx,$dy) = @_;
 $self->{stream} .="$x $y $dx $dy re\nF\n"}

1;
