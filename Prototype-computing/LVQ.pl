#!/usr/bin/perl -w
#Ausfuehrung :  ./LVQ.pl

use strict;
use warnings;
use List::Util 'shuffle';
use List::Util qw( min max first );
use Time::Duration;

print "LVQ Algorithm for prototype computation!\n";

############################## LVQ - Algorithmus ###########################################################################

my $file = $ENV{training};
my @Zeilen =();

open( my $TEST, "<", $file) or die("$!");                           # oeffnen der Datei des Trainings
    while(my $line = <$TEST>)                                       # fuer jede Zeile in der Datei
    {
        chomp $line;                                                # entfernt leerzeichen vor und newline hinter der Zeile
        
        my @fields = split "\t" , $line;                            # splitte die Zeile nach jedem Tab
        @Zeilen = (@Zeilen,[@fields]);                              # speichere die Werte in Zeilen
    }
close($TEST);


my $start = time();                                                 # Start der Berechnung

my $i;                                                              # Hilfsvariable
my @foo;                                                            # Fuer die Erstellung der Prototypenmenge
my @bar;                                                            # Abspeichern der Klassenzugehoerigkeit der Indize 

my $ocode = $ENV{composition};
my $o = 4**$ocode;                                                  # Oligonukleotide, 2-di, 3-tri, 4-tetra
my $c = $o+1;                                                       # Klasseneinteilung DNA/RNA

my $line=0;
$i=0;
for(@Zeilen){
    
    if($i > 0){                                                     # muss durchgefuehrt werden, da die 0-te Zeile der Header ist
        $line = @{$_}[$c];
        if ($line == 1)
        {
            @foo = (@foo,$_);
        }else{
            @bar = (@bar,$_);
        }
    }
    $line=0;
    $i++;
}

my $erg2=0, my $xclass, my $pclass;
my $alpha, my $oli;
my @wurzel;
my @werte, my @w2,my @erg, my @erg1, my @change, my @hilf, my @protos;

my $W = 1;
my @n = split /,/, $ENV{n};
my @T = split /,/, $ENV{T};

if($o==16){
    $oli="di";
}elsif($o==64){
    $oli="tri";
}else{
    $oli="tetra";
}

for(@T){
    my $T=$_;
    for(@n){
        my $n=$_;
        print $T," Learning steps and ",$n," prototypes per class.\n";
        print $oli,"nucleotides are used.\n";
        for my $wdh (1..$W){
        
            @foo = shuffle(@foo);
            @bar = shuffle(@bar);
            
            my @foos = @foo[0..($n-1)];
            my @bars = @bar[0..($n-1)];
            push(@protos, @foos);         # Abspeichern der zufaelligen Initialprototypen
            push(@protos, @bars);
            
            for my $t (1..$T){
                $i=0;
                $alpha = 1/(4*($t*$t));
                for(@Zeilen){
                    if($i > 0){
                        @werte = @{$_}[1..$o];                                  # speichern des aktuellen Vektors
                        $xclass = @{$_}[$c];
                        for my $prot (@protos){
                            @change = @{$prot}[1..$o];
                            
                            @erg = map {$werte[$_] - $change[$_]} 0..$#werte;
                            
                            @erg1 = map {$erg[$_] * $erg[$_]} 0..$#erg;
                            
                            $erg2 += $_ foreach(@erg1);
                            
                            @wurzel = (@wurzel,sqrt($erg2));
                            
                            $erg2=0;
                        }
                        undef(@erg);
                        undef(@erg1);
                        undef(@change);
                        
                        my $min = min(@wurzel);
                        my $idx = first { $wurzel[$_] eq $min } 0..$#wurzel;
                        
                        undef(@wurzel);
                        
                        $pclass = $protos[$idx][$c];
                        @change = @{$protos[$idx]}[1..$o];
                        if ($xclass eq $pclass){
                            
                            @erg = map {$werte[$_] - $change[$_]} 0..$#werte;
                            
                            @erg = map {$_ * $alpha} @erg;
                            
                            @hilf = map {$change[$_] + $erg[$_]} 0..$#erg;
                            
                            splice(@{$protos[$idx]},1,$o,@hilf);
                        }else{
                            @erg = map {$werte[$_] - $change[$_]} 0..$#werte;
                            
                            @erg = map {$_ * $alpha} @erg;
                            
                            @hilf = map {$change[$_] - $erg[$_]} 0..$#erg;
                            splice(@{$protos[$idx]},1,$o,@hilf);
                        }
                        
                        undef(@erg);
                        undef(@hilf);
                        undef(@change);
                    }
                    $i++;
                }
            }
            my $path = $ENV{path};
            my $file2 = join("",$path,"proto_",$oli,"_ls_",$T,"_apk_",$n,".txt");
            
            open( my $TEST2, ">", $file2);                   # oeffnen der Datei
                local $" = "\t";
                local $, = "\t";
                
                my $ende = $#{$Zeilen[0]}-1;
                print $TEST2 "$Zeilen[0][$_]\t" for 0..$ende;
                print $TEST2 "$Zeilen[0][$_]\n" for $#{$Zeilen[0]};
                print $TEST2 "@{$protos[$_]}\n" for 0..$#protos;
            close($TEST2);
            
            undef(@protos);
            undef($TEST2);
            
            print "--------------------------------------\n";
        
        }
    }
}
my $end = time();
my $diff = duration( $end - $start );

print "The computation took $diff.\n";
