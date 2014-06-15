package PDF::API2::Resource::XObject::Form::BarCode::code3of9;

# VERSION

use base 'PDF::API2::Resource::XObject::Form::BarCode';

use strict;
use warnings;

sub new {
    my ($class, $pdf, %options) = @_;
    my $self = $class->SUPER::new($pdf, %options);

    my @bars = encode_3of9($options{'-code'},
                           $options{'-chk'} ? 1 : 0,
                           $options{'-ext'} ? 1 : 0);

    $self->drawbar([@bars]);

    return $self;
}

my $code3of9 = q(0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*);

my @bar3of9 = qw(
    1112212111  2112111121  1122111121  2122111111
    1112211121  2112211111  1122211111  1112112121
    2112112111  1122112111  2111121121  1121121121
    2121121111  1111221121  2111221111  1121221111
    1111122121  2111122111  1121122111  1111222111
    2111111221  1121111221  2121111211  1111211221
    2111211211  1121211211  1111112221  2111112211
    1121112211  1111212211  2211111121  1221111121
    2221111111  1211211121  2211211111  1221211111
    1211112121  2211112111  1221112111  1212121111
    1212111211  1211121211  1112121211  abaababaa1
);

my %bar3of9ext = (
    "\x00" => '%U',
    "\x01" => '$A',
    "\x02" => '$B',
    "\x03" => '$C',
    "\x04" => '$D',
    "\x05" => '$E',
    "\x06" => '$F',
    "\x07" => '$G',
    "\x08" => '$H',
    "\x09" => '$I',
    "\x0a" => '$J',
    "\x0b" => '$K',
    "\x0c" => '$L',
    "\x0d" => '$M',
    "\x0e" => '$N',
    "\x0f" => '$O',
    "\x10" => '$P',
    "\x11" => '$Q',
    "\x12" => '$R',
    "\x13" => '$S',
    "\x14" => '$T',
    "\x15" => '$U',
    "\x16" => '$V',
    "\x17" => '$W',
    "\x18" => '$X',
    "\x19" => '$Y',
    "\x1a" => '$Z',
    "\x1b" => '%A',
    "\x1c" => '%B',
    "\x1d" => '%C',
    "\x1e" => '%D',
    "\x1f" => '$E',
    "\x20" => ' ',
    "!" => '/A',
    '"' => '/B',
    "#" => '/C',
    '$' => '/D',
    '%' => '/E',
    '&' => '/F',
    "'" => '/G',
    '(' => '/H',
    ')' => '/I',
    '*' => '/J',
    '+' => '/K',
    ',' => '/L',
    '-' => '-',
    '.' => '.',
    '/' => '/O',
    '0' => '0',
    '1' => '1',
    '2' => '2',
    '3' => '3',
    '4' => '4',
    '5' => '5',
    '6' => '6',
    '7' => '7',
    '8' => '8',
    '9' => '9',
    ':' => '/Z',
    ';' => '%F',
    '<' => '%G',
    '=' => '%H',
    '>' => '%I',
    '?' => '%J',
    '@' => '%V',
    'A' => 'A',
    'B' => 'B',
    'C' => 'C',
    'D' => 'D',
    'E' => 'E',
    'F' => 'F',
    'G' => 'G',
    'H' => 'H',
    'I' => 'I',
    'J' => 'J',
    'K' => 'K',
    'L' => 'L',
    'M' => 'M',
    'N' => 'N',
    'O' => 'O',
    'P' => 'P',
    'Q' => 'Q',
    'R' => 'R',
    'S' => 'S',
    'T' => 'T',
    'U' => 'U',
    'V' => 'V',
    'W' => 'W',
    'X' => 'X',
    'Y' => 'Y',
    'Z' => 'Z',
    '[' => '%K',
    '\\' => '%L',
    ']' => '%M',
    '^' => '%N',
    '_' => '%O',
    '`' => '%W',
    'a' => '+A',
    'b' => '+B',
    'c' => '+C',
    'd' => '+D',
    'e' => '+E',
    'f' => '+F',
    'g' => '+G',
    'h' => '+H',
    'i' => '+I',
    'j' => '+J',
    'k' => '+K',
    'l' => '+L',
    'm' => '+M',
    'n' => '+N',
    'o' => '+O',
    'p' => '+P',
    'q' => '+Q',
    'r' => '+R',
    's' => '+S',
    't' => '+T',
    'u' => '+U',
    'v' => '+V',
    'w' => '+W',
    'x' => '+X',
    'y' => '+Y',
    'z' => '+Z',
    '{' => '%P',
    '|' => '%Q',
    '}' => '%R',
    '~' => '%S',
    "\x7f" => '%T'
);

sub encode_3of9_char {
    my $character = shift();
    return $bar3of9[index($code3of9, $character)];
}

sub encode_3of9_string {
    my ($string, $is_mod43) = @_;

    my $bar;
    my $checksum = 0;
    foreach my $char (split //, $string) {
        $bar .= encode_3of9_char($char);
        $checksum += index($code3of9, $char);
    }

    if ($is_mod43) {
        $checksum %= 43;
        $bar .= $bar3of9[$checksum];
    }

    return $bar;
}

# Deprecated (rolled into encode_3of9_string)
sub encode_3of9_string_w_chk { return encode_3of9_string(shift(), 1); }

sub encode_3of9 {
    my ($string, $is_mod43, $is_extended) = @_;

    my $display;
    unless ($is_extended) {
        $string = uc $string;
        $string =~ s/[^0-9A-Z\-\.\ \$\/\+\%]+//g;
        $display = $string;
    }
    else {
        # Extended Code39 supports all 7-bit ASCII characters
        $string =~ s/[^\x00-\x7f]//g;
        $display = $string;

        # Encode, but don't display, non-printable characters
        $display =~ s/[:cntrl:]//g;

        $string = join('', map { $bar3of9ext{$_} } split //, $string);
    }

    my @bars;
    push @bars, encode_3of9_char('*');
    push @bars, [ encode_3of9_string($string, $is_mod43), $display ];
    push @bars, encode_3of9_char('*');
    return @bars;
}

# Deprecated (rolled into encode_3of9)
sub encode_3of9_w_chk     { return encode_3of9(shift(), 1, 0); }
sub encode_3of9_ext       { return encode_3of9(shift(), 0, 1); }
sub encode_3of9_ext_w_chk { return encode_3of9(shift(), 1, 1); }

1;
