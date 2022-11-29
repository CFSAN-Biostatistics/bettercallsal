#!/usr/bin/env perl

# Kranti Konganti
# Takes in a gzipped multi-fasta file
# and joins contigs by 10 N's

use strict;
use warnings;
use Cwd;
use Bio::SeqIO;
use Getopt::Long;
use File::Find;
use File::Basename;
use File::Spec::Functions;

my ( $in_dir, $out_dir, $suffix, @uncatted_genomes );

GetOptions(
    'in_dir=s'  => \$in_dir,
    'out_dir=s' => \$out_dir,
    'suffix=s'  => \$suffix
) or die usage();

$in_dir  = getcwd            if ( !defined $in_dir );
$out_dir = getcwd            if ( !defined $out_dir );
$suffix  = '_genomic.fna.gz' if ( !defined $suffix );

find(
    {
        wanted => sub {
            push @uncatted_genomes, $File::Find::name if ( $_ =~ m/$suffix$/ );
        }
    },
    $in_dir
);

if ( $out_dir ne getcwd && !-d $out_dir ) {
    mkdir $out_dir || die "\nCannot create directory $out_dir: $!\n\n";
}

open( my $geno_path, '>genome_paths.txt' )
  || die "\nCannot open file genome_paths.txt: $!\n\n";

foreach my $uncatted_genome_path (@uncatted_genomes) {
    my $catted_genome_header = '>' . basename( $uncatted_genome_path, $suffix );
    $catted_genome_header =~ s/(GC[AF]\_\d+\.\d+)\_*.*/$1/;

    my $catted_genome =
      catfile( $out_dir, $catted_genome_header . '_scaffolded' . $suffix );

    $catted_genome =~ s/\/\>(GC[AF])/\/$1/;

    print $geno_path "$catted_genome\n";

    open( my $fh, "gunzip -c $uncatted_genome_path |" )
      || die "\nCannot create pipe for $uncatted_genome_path: $!\n\n";

    open( my $fho, '|-', "gzip -c > $catted_genome" )
      || die "\nCannot pipe to gzip: $!\n\n";

    my $seq_obj = Bio::SeqIO->new(
        -fh     => $fh,
        -format => 'Fasta'
    );

    my $joined_seq = '';
    while ( my $seq = $seq_obj->next_seq ) {
        $joined_seq = $joined_seq . 'NNNNNNNNNN' . $seq->seq;
    }

    $joined_seq =~ s/NNNNNNNNNN$//;
    $joined_seq =~ s/^NNNNNNNNNN//;

    # $joined_seq =~ s/.{80}\K/\n/g;
    # $joined_seq =~ s/\n$//;
    print $fho $catted_genome_header, "\n", $joined_seq, "\n";

    $seq_obj->close();
    close $fh;
    close $fho;
}

sub usage {
    print
"\nUsage: $0 [-in IN_DIR] [-ou OUT_DIR] [-su Filename Suffix for Header]\n\n";
    exit;
}

