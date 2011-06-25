# Copyright 2011 Kevin Ryde

# Generated by make-oeis-catalogue.pl -- DO NOT EDIT

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

package App::MathImage::NumSeq::OeisCatalogue::Plugin::BuiltinTable;
use strict;
use warnings;

use vars '$VERSION', '@ISA';
$VERSION = 61;
use App::MathImage::NumSeq::OeisCatalogue::Base;
@ISA = ('App::MathImage::NumSeq::OeisCatalogue::Base');

use constant info_arrayref =>
[
  {
    'anum' => 'A005101',
    'class' => 'App::MathImage::NumSeq::Sequence::Abundant'
  },
  {
    'anum' => 'A000027',
    'class' => 'App::MathImage::NumSeq::Sequence::All'
  },
  {
    'anum' => 'A023717',
    'class' => 'App::MathImage::NumSeq::Sequence::Base4Without3'
  },
  {
    'anum' => 'A051003',
    'class' => 'App::MathImage::NumSeq::Sequence::Beastly',
    'parameters_hashref' => {
      'radix' => 10
    }
  },
  {
    'anum' => 'A030303',
    'class' => 'App::MathImage::NumSeq::Sequence::ChampernowneBinary'
  },
  {
    'anum' => 'A000578',
    'class' => 'App::MathImage::NumSeq::Sequence::Cubes'
  },
  {
    'anum' => 'A002064',
    'class' => 'App::MathImage::NumSeq::Sequence::CullenNumbers'
  },
  {
    'anum' => 'A070939',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitLength',
    'parameters_hashref' => {
      'radix' => 2
    }
  },
  {
    'anum' => 'A083652',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitLengthCumulative',
    'parameters_hashref' => {
      'radix' => 2
    }
  },
  {
    'anum' => 'A010060',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 2
    }
  },
  {
    'anum' => 'A053838',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 3
    }
  },
  {
    'anum' => 'A053839',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 4
    }
  },
  {
    'anum' => 'A053840',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 5
    }
  },
  {
    'anum' => 'A053841',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 6
    }
  },
  {
    'anum' => 'A053842',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 7
    }
  },
  {
    'anum' => 'A053843',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 8
    }
  },
  {
    'anum' => 'A053844',
    'class' => 'App::MathImage::NumSeq::Sequence::DigitSumModulo',
    'parameters_hashref' => {
      'radix' => 9
    }
  },
  {
    'anum' => 'A006567',
    'class' => 'App::MathImage::NumSeq::Sequence::Emirps',
    'parameters_hashref' => {
      'radix' => 10
    }
  },
  {
    'anum' => 'A005843',
    'class' => 'App::MathImage::NumSeq::Sequence::Even'
  },
  {
    'anum' => 'A000142',
    'class' => 'App::MathImage::NumSeq::Sequence::Factorials'
  },
  {
    'anum' => 'A000045',
    'class' => 'App::MathImage::NumSeq::Sequence::Fibonacci'
  },
  {
    'anum' => 'A020806',
    'class' => 'App::MathImage::NumSeq::Sequence::FractionDigits',
    'parameters_hashref' => {
      'fraction' => '1/7',
      'radix' => 10
    }
  },
  {
    'anum' => 'A068028',
    'class' => 'App::MathImage::NumSeq::Sequence::FractionDigits',
    'parameters_hashref' => {
      'fraction' => '22/7',
      'radix' => 10
    }
  },
  {
    'anum' => 'A010680',
    'class' => 'App::MathImage::NumSeq::Sequence::FractionDigits',
    'parameters_hashref' => {
      'fraction' => '1/11',
      'radix' => 10
    }
  },
  {
    'anum' => 'A022155',
    'class' => 'App::MathImage::NumSeq::Sequence::GolayRudinShapiro'
  },
  {
    'anum' => 'A000161',
    'class' => 'App::MathImage::NumSeq::Sequence::HypotCount'
  },
  {
    'anum' => 'A003136',
    'class' => 'App::MathImage::NumSeq::Sequence::LoeschianNumbers'
  },
  {
    'anum' => 'A000204',
    'class' => 'App::MathImage::NumSeq::Sequence::Lucas'
  },
  {
    'anum' => 'A008683',
    'class' => 'App::MathImage::NumSeq::Sequence::MobiusFunction'
  },
  {
    'anum' => 'A079000',
    'class' => 'App::MathImage::NumSeq::Sequence::NumaronsonA'
  },
  {
    'anum' => 'A133122',
    'class' => 'App::MathImage::NumSeq::Sequence::Obstinate'
  },
  {
    'anum' => 'A005408',
    'class' => 'App::MathImage::NumSeq::Sequence::Odd'
  },
  {
    'anum' => 'A006995',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 2
    }
  },
  {
    'anum' => 'A014190',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 3
    }
  },
  {
    'anum' => 'A014192',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 4
    }
  },
  {
    'anum' => 'A029952',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 5
    }
  },
  {
    'anum' => 'A029953',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 6
    }
  },
  {
    'anum' => 'A029954',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 7
    }
  },
  {
    'anum' => 'A029803',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 8
    }
  },
  {
    'anum' => 'A029955',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 9
    }
  },
  {
    'anum' => 'A002113',
    'class' => 'App::MathImage::NumSeq::Sequence::Palindromes',
    'parameters_hashref' => {
      'radix' => 10
    }
  },
  {
    'anum' => 'A000129',
    'class' => 'App::MathImage::NumSeq::Sequence::Pell'
  },
  {
    'anum' => 'A001608',
    'class' => 'App::MathImage::NumSeq::Sequence::Perrin'
  },
  {
    'anum' => 'A059253',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'X',
      'planepath_class' => 'HilbertCurve'
    }
  },
  {
    'anum' => 'A059252',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'Y',
      'planepath_class' => 'HilbertCurve'
    }
  },
  {
    'anum' => 'A163528',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'X',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A163529',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'Y',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A163530',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'Sum',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A163531',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathCoord',
    'parameters_hashref' => {
      'coord_type' => 'SqDist',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A163538',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathDelta',
    'parameters_hashref' => {
      'delta_type' => 'x',
      'planepath_class' => 'HilbertCurve'
    }
  },
  {
    'anum' => 'A163539',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathDelta',
    'parameters_hashref' => {
      'delta_type' => 'y',
      'planepath_class' => 'HilbertCurve'
    }
  },
  {
    'anum' => 'A163532',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathDelta',
    'parameters_hashref' => {
      'delta_type' => 'x',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A163533',
    'class' => 'App::MathImage::NumSeq::Sequence::PlanePathDelta',
    'parameters_hashref' => {
      'delta_type' => 'y',
      'planepath_class' => 'PeanoCurve'
    }
  },
  {
    'anum' => 'A000326',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 5
    }
  },
  {
    'anum' => 'A005449',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'second',
      'polygonal' => 5
    }
  },
  {
    'anum' => 'A001318',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'both',
      'polygonal' => 5
    }
  },
  {
    'anum' => 'A000384',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 6
    }
  },
  {
    'anum' => 'A014105',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'second',
      'polygonal' => 6
    }
  },
  {
    'anum' => 'A000566',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 7
    }
  },
  {
    'anum' => 'A000567',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 8
    }
  },
  {
    'anum' => 'A001106',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 9
    }
  },
  {
    'anum' => 'A001107',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 10
    }
  },
  {
    'anum' => 'A051682',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 11
    }
  },
  {
    'anum' => 'A051624',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 12
    }
  },
  {
    'anum' => 'A051865',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 13
    }
  },
  {
    'anum' => 'A051866',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 14
    }
  },
  {
    'anum' => 'A051867',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 15
    }
  },
  {
    'anum' => 'A051868',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 16
    }
  },
  {
    'anum' => 'A051869',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 17
    }
  },
  {
    'anum' => 'A051870',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 18
    }
  },
  {
    'anum' => 'A051871',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 19
    }
  },
  {
    'anum' => 'A051872',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 20
    }
  },
  {
    'anum' => 'A051873',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 21
    }
  },
  {
    'anum' => 'A051874',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 22
    }
  },
  {
    'anum' => 'A051875',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 23
    }
  },
  {
    'anum' => 'A051876',
    'class' => 'App::MathImage::NumSeq::Sequence::Polygonal',
    'parameters_hashref' => {
      'pairs' => 'first',
      'polygonal' => 24
    }
  },
  {
    'anum' => 'A001221',
    'class' => 'App::MathImage::NumSeq::Sequence::PrimeFactorCount',
    'parameters_hashref' => {
      'multiplicity' => 'distinct'
    }
  },
  {
    'anum' => 'A001222',
    'class' => 'App::MathImage::NumSeq::Sequence::PrimeFactorCount',
    'parameters_hashref' => {
      'multiplicity' => 'repeated'
    }
  },
  {
    'anum' => 'A006450',
    'class' => 'App::MathImage::NumSeq::Sequence::PrimeIndexPrimes'
  },
  {
    'anum' => 'A000040',
    'class' => 'App::MathImage::NumSeq::Sequence::Primes'
  },
  {
    'anum' => 'A002110',
    'class' => 'App::MathImage::NumSeq::Sequence::Primorials'
  },
  {
    'anum' => 'A002378',
    'class' => 'App::MathImage::NumSeq::Sequence::Pronic'
  },
  {
    'anum' => 'A080075',
    'class' => 'App::MathImage::NumSeq::Sequence::ProthNumbers'
  },
  {
    'anum' => 'A009003',
    'class' => 'App::MathImage::NumSeq::Sequence::PythagoreanHypots'
  },
  {
    'anum' => 'A032924',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 0,
      'radix' => 3
    }
  },
  {
    'anum' => 'A005823',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 1,
      'radix' => 3
    }
  },
  {
    'anum' => 'A023705',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 0,
      'radix' => 4
    }
  },
  {
    'anum' => 'A023709',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 1,
      'radix' => 4
    }
  },
  {
    'anum' => 'A023713',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 2,
      'radix' => 4
    }
  },
  {
    'anum' => 'A023721',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 0,
      'radix' => 5
    }
  },
  {
    'anum' => 'A023725',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 1,
      'radix' => 5
    }
  },
  {
    'anum' => 'A023729',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 2,
      'radix' => 5
    }
  },
  {
    'anum' => 'A023733',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 3,
      'radix' => 5
    }
  },
  {
    'anum' => 'A023737',
    'class' => 'App::MathImage::NumSeq::Sequence::RadixWithoutDigit',
    'parameters_hashref' => {
      'digit' => 4,
      'radix' => 5
    }
  },
  {
    'anum' => 'A167782',
    'class' => 'App::MathImage::NumSeq::Sequence::RepdigitAnyBase'
  },
  {
    'anum' => 'A010785',
    'class' => 'App::MathImage::NumSeq::Sequence::Repdigits',
    'parameters_hashref' => {
      'radix' => 10
    }
  },
  {
    'anum' => 'A030547',
    'class' => 'App::MathImage::NumSeq::Sequence::ReverseAddSteps',
    'parameters_hashref' => {
      'radix' => 10
    }
  },
  {
    'anum' => 'A005385',
    'class' => 'App::MathImage::NumSeq::Sequence::SafePrimes'
  },
  {
    'anum' => 'A001358',
    'class' => 'App::MathImage::NumSeq::Sequence::SemiPrimes'
  },
  {
    'anum' => 'A005384',
    'class' => 'App::MathImage::NumSeq::Sequence::SophieGermainPrimes'
  },
  {
    'anum' => 'A004539',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 2,
      'sqrt' => 2
    }
  },
  {
    'anum' => 'A004540',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 3,
      'sqrt' => 2
    }
  },
  {
    'anum' => 'A004541',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 4,
      'sqrt' => 2
    }
  },
  {
    'anum' => 'A004542',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 5,
      'sqrt' => 2
    }
  },
  {
    'anum' => 'A002193',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 2
    }
  },
  {
    'anum' => 'A002194',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 3
    }
  },
  {
    'anum' => 'A002163',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 5
    }
  },
  {
    'anum' => 'A010467',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 10
    }
  },
  {
    'anum' => 'A010468',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 11
    }
  },
  {
    'anum' => 'A010469',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 12
    }
  },
  {
    'anum' => 'A010470',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 13
    }
  },
  {
    'anum' => 'A010471',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 14
    }
  },
  {
    'anum' => 'A010472',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 15
    }
  },
  {
    'anum' => 'A010473',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 17
    }
  },
  {
    'anum' => 'A010474',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 18
    }
  },
  {
    'anum' => 'A010475',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 19
    }
  },
  {
    'anum' => 'A010476',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 20
    }
  },
  {
    'anum' => 'A010477',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 21
    }
  },
  {
    'anum' => 'A010478',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 22
    }
  },
  {
    'anum' => 'A010479',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 23
    }
  },
  {
    'anum' => 'A010480',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 24
    }
  },
  {
    'anum' => 'A010481',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 26
    }
  },
  {
    'anum' => 'A010482',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 27
    }
  },
  {
    'anum' => 'A010483',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 28
    }
  },
  {
    'anum' => 'A010484',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 29
    }
  },
  {
    'anum' => 'A010485',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 30
    }
  },
  {
    'anum' => 'A010486',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 31
    }
  },
  {
    'anum' => 'A010487',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 32
    }
  },
  {
    'anum' => 'A010488',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 33
    }
  },
  {
    'anum' => 'A010489',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 34
    }
  },
  {
    'anum' => 'A010490',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 35
    }
  },
  {
    'anum' => 'A010491',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 37
    }
  },
  {
    'anum' => 'A010492',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 38
    }
  },
  {
    'anum' => 'A010493',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 39
    }
  },
  {
    'anum' => 'A010494',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 40
    }
  },
  {
    'anum' => 'A010495',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 41
    }
  },
  {
    'anum' => 'A010496',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 42
    }
  },
  {
    'anum' => 'A010497',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 43
    }
  },
  {
    'anum' => 'A010498',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 44
    }
  },
  {
    'anum' => 'A010499',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 45
    }
  },
  {
    'anum' => 'A010500',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 46
    }
  },
  {
    'anum' => 'A010501',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 47
    }
  },
  {
    'anum' => 'A010502',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 48
    }
  },
  {
    'anum' => 'A010503',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 50
    }
  },
  {
    'anum' => 'A010504',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 51
    }
  },
  {
    'anum' => 'A010505',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 52
    }
  },
  {
    'anum' => 'A010506',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 53
    }
  },
  {
    'anum' => 'A010507',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 54
    }
  },
  {
    'anum' => 'A010508',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 55
    }
  },
  {
    'anum' => 'A010509',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 56
    }
  },
  {
    'anum' => 'A010510',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 57
    }
  },
  {
    'anum' => 'A010511',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 58
    }
  },
  {
    'anum' => 'A010512',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 59
    }
  },
  {
    'anum' => 'A010513',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 60
    }
  },
  {
    'anum' => 'A010514',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 61
    }
  },
  {
    'anum' => 'A010515',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 62
    }
  },
  {
    'anum' => 'A010516',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 63
    }
  },
  {
    'anum' => 'A010517',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 65
    }
  },
  {
    'anum' => 'A010518',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 66
    }
  },
  {
    'anum' => 'A010519',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 67
    }
  },
  {
    'anum' => 'A010520',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 68
    }
  },
  {
    'anum' => 'A010521',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 69
    }
  },
  {
    'anum' => 'A010522',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 70
    }
  },
  {
    'anum' => 'A010523',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 71
    }
  },
  {
    'anum' => 'A010524',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 72
    }
  },
  {
    'anum' => 'A010525',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 73
    }
  },
  {
    'anum' => 'A010526',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 74
    }
  },
  {
    'anum' => 'A010527',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 75
    }
  },
  {
    'anum' => 'A010528',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 76
    }
  },
  {
    'anum' => 'A010529',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 77
    }
  },
  {
    'anum' => 'A010530',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 78
    }
  },
  {
    'anum' => 'A010531',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 79
    }
  },
  {
    'anum' => 'A010532',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 80
    }
  },
  {
    'anum' => 'A010533',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 82
    }
  },
  {
    'anum' => 'A010534',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 83
    }
  },
  {
    'anum' => 'A010535',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 84
    }
  },
  {
    'anum' => 'A010536',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 84
    }
  },
  {
    'anum' => 'A010537',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 86
    }
  },
  {
    'anum' => 'A010538',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 87
    }
  },
  {
    'anum' => 'A010539',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 88
    }
  },
  {
    'anum' => 'A010540',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 89
    }
  },
  {
    'anum' => 'A010541',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 90
    }
  },
  {
    'anum' => 'A010542',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 91
    }
  },
  {
    'anum' => 'A010543',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 92
    }
  },
  {
    'anum' => 'A010544',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 93
    }
  },
  {
    'anum' => 'A010545',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 94
    }
  },
  {
    'anum' => 'A010546',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 95
    }
  },
  {
    'anum' => 'A010547',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 96
    }
  },
  {
    'anum' => 'A010548',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 97
    }
  },
  {
    'anum' => 'A010549',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 98
    }
  },
  {
    'anum' => 'A010550',
    'class' => 'App::MathImage::NumSeq::Sequence::SqrtDigits',
    'parameters_hashref' => {
      'radix' => 10,
      'sqrt' => 99
    }
  },
  {
    'anum' => 'A000290',
    'class' => 'App::MathImage::NumSeq::Sequence::Squares'
  },
  {
    'anum' => 'A003154',
    'class' => 'App::MathImage::NumSeq::Sequence::StarNumbers'
  },
  {
    'anum' => 'A000404',
    'class' => 'App::MathImage::NumSeq::Sequence::SumTwoSquares'
  },
  {
    'anum' => 'A092572',
    'class' => 'App::MathImage::NumSeq::Sequence::SumXsq3Ysq'
  },
  {
    'anum' => 'A005836',
    'class' => 'App::MathImage::NumSeq::Sequence::TernaryWithout2'
  },
  {
    'anum' => 'A000292',
    'class' => 'App::MathImage::NumSeq::Sequence::Tetrahedral'
  },
  {
    'anum' => 'A003434',
    'class' => 'App::MathImage::NumSeq::Sequence::TotientSteps'
  },
  {
    'anum' => 'A002088',
    'class' => 'App::MathImage::NumSeq::Sequence::TotientSum'
  },
  {
    'anum' => 'A000217',
    'class' => 'App::MathImage::NumSeq::Sequence::Triangular'
  },
  {
    'anum' => 'A000073',
    'class' => 'App::MathImage::NumSeq::Sequence::Tribonacci'
  },
  {
    'anum' => 'A001359',
    'class' => 'App::MathImage::NumSeq::Sequence::TwinPrimes',
    'parameters_hashref' => {
      'pairs' => 'first'
    }
  },
  {
    'anum' => 'A006512',
    'class' => 'App::MathImage::NumSeq::Sequence::TwinPrimes',
    'parameters_hashref' => {
      'pairs' => 'second'
    }
  },
  {
    'anum' => 'A001097',
    'class' => 'App::MathImage::NumSeq::Sequence::TwinPrimes',
    'parameters_hashref' => {
      'pairs' => 'both'
    }
  },
  {
    'anum' => 'A003261',
    'class' => 'App::MathImage::NumSeq::Sequence::WoodallNumbers'
  }
]
;
1;
__END__
