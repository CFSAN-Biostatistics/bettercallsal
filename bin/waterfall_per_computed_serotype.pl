#!/usr/bin/env perl

# Kranti Konganti
# 09/14/2022

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use File::Basename;
use File::Spec::Functions;

my $tbl           = {};
my $serovar_2_acc = {};
my $acc_2_serovar = {};
my $acc_2_target  = {};
my $serovar_count = {};
my (
    $serovar_limit,          $serovar_or_type_col, $min_asm_size,
    $complete_serotype_name, $PDG_file,            $table_file,
    $not_null_pdg_serovar,   $help,                $out_prefix,
    @custom_serovars
);

GetOptions(
    'help'                         => \$help,
    'pdg=s'                        => \$PDG_file,
    'tbl=s'                        => \$table_file,
    'min_contig_size=i'            => \$min_asm_size,
    'complete_serotype_name'       => \$complete_serotype_name,
    'serotype_col:i'               => \$serovar_or_type_col,
    'not_null_pdg_serovar'         => \$not_null_pdg_serovar,
    'num_serotypes_per_serotype:i' => \$serovar_limit,
    'include_serovar=s'            => \@custom_serovars,
    'op=s'                         => \$out_prefix
) or pod2usage( -verbose => 2 );

if ( !defined $serovar_limit ) {
    $serovar_limit = 10;
}

if ( !defined $serovar_or_type_col ) {
    $serovar_or_type_col = 49;
}

if ( !defined $min_asm_size ) {
    $min_asm_size = 0;
}

if ( defined $out_prefix ) {
    $out_prefix .= '_';
}
else {
    $out_prefix = '';
}

pod2usage( -verbose => 2 ) if ( !defined $PDG_file || !defined $table_file );

open( my $pdg_file, '<', $PDG_file )
  || die "\nCannot open PDG file $PDG_file: $!\n\n";
open( my $tbl_file, '<', $table_file )
  || die "\nCannot open tbl file $table_file: $!\n\n";
open( my $Stdout,      '>&', STDOUT ) || die "\nCannot pipe to STDOUT: $!\n\n";
open( my $Stderr,      '>&', STDERR ) || die "\nCannot pipe to STDERR: $!\n\n";
open( my $accs_cmp_fh, '>',  $out_prefix . 'accs_comp.txt' )
  || die "\nCannnot open " . $out_prefix . "accs_comp.txt for writing: $!\n\n";
open( my $genome_headers_fh, '>', $out_prefix . 'mash_comp_genome_list.txt' )
  || die "\nCannnot open "
  . $out_prefix
  . "mash_comp_genome_list.txt for writing: $!\n\n";

my $pdg_release = basename( $PDG_file, ".metadata.tsv" );

while ( my $line = <$pdg_file> ) {
    chomp $line;
    next if ( $line =~ m/^\#/ );

    # Relevent columns (Perl index):
    #  9: asm_acc
    # 33: serovar
    # 48: computed serotype

    my @cols            = split( /\t/, $line );
    my $serovar_or_type = $cols[ $serovar_or_type_col - 1 ];
    my $acc             = $cols[9];
    my $serovar         = $cols[33];
    my $target_acc      = $cols[41];

    $serovar_or_type =~ s/\"//g;

    my $skip = 1;
    foreach my $ser (@custom_serovars) {
        $skip = 0, next if ( $serovar_or_type =~ qr/\Q$ser\E/ );
    }

    if ( defined $complete_serotype_name ) {
        next
          if ( $skip
            && ( $serovar_or_type =~ m/serotype=.*?\-.*?\,antigen_formula.+/ )
          );
    }

    next
      if (
        $skip
        && (   $serovar_or_type =~ m/serotype=\-\s+\-\:\-\:\-/
            || $serovar_or_type =~ m/antigen_formula=\-\:\-\:\-/ )
      );

    if ( defined $not_null_pdg_serovar ) {
        if (   $acc !~ m/NULL/
            && $serovar         !~ m/NULL/
            && $serovar_or_type !~ m/NULL/ )
        {
            $acc_2_serovar->{$acc} = $serovar_or_type;
            $acc_2_target->{$acc}  = $target_acc;
        }
    }
    elsif ( $acc !~ m/NULL/ && $serovar_or_type !~ m/NULL/ ) {
        $acc_2_serovar->{$acc} = $serovar_or_type;
        $acc_2_target->{$acc}  = $target_acc;
    }
    $serovar_count->{$serovar_or_type} = 0;
}

while ( my $line = <$tbl_file> ) {
    chomp $line;

    my @cols = split( /\t/, $line );

    # .tbl file columns (Perl index):
    #
    # 0: Accession
    # 1: AssemblyLevel
    # 2: ScaffoldN50
    # 3: ContigN50

    my $acc          = $cols[0];
    my $asm_lvl      = $cols[1];
    my $scaffold_n50 = $cols[2];
    my $contig_n50   = $cols[3];

    if ( not_empty($acc) && exists( $acc_2_serovar->{$acc} ) ) {
        my $fna_rel_loc =
            "$pdg_release/ncbi_dataset/data/$acc/"
          . $acc
          . '_scaffolded_genomic.fna.gz';

        if ( not_empty($scaffold_n50) ) {
            next if ( $scaffold_n50 <= $min_asm_size );
            push @{ $serovar_2_acc->{ $acc_2_serovar->{$acc} }
                  ->{ sort_asm_level($asm_lvl) }->{$scaffold_n50} },
              $fna_rel_loc;
        }
        elsif ( not_empty($contig_n50) ) {
            next if ( $contig_n50 <= $min_asm_size );
            push @{ $serovar_2_acc->{ $acc_2_serovar->{$acc} }
                  ->{ sort_asm_level($asm_lvl) }->{$contig_n50} }, $fna_rel_loc;
        }
    }
}

foreach my $serovar ( sort { $a cmp $b } keys %$serovar_2_acc ) {
    foreach
      my $asm_lvl ( sort { $a cmp $b } keys %{ $serovar_2_acc->{$serovar} } )
    {
        if ( $asm_lvl =~ m/Complete\s+Genome/i ) {
            $serovar_count->{$serovar} = print_dl_metadata(
                $serovar, $asm_lvl,
                \$serovar_2_acc->{$serovar}->{$asm_lvl},
                $serovar_count->{$serovar}
            );
        }
        if ( $asm_lvl =~ m/Chromosome/i ) {
            $serovar_count->{$serovar} = print_dl_metadata(
                $serovar, $asm_lvl,
                \$serovar_2_acc->{$serovar}->{$asm_lvl},
                $serovar_count->{$serovar}
            );
        }
        if ( $asm_lvl =~ m/Scaffold/i ) {
            $serovar_count->{$serovar} = print_dl_metadata(
                $serovar, $asm_lvl,
                \$serovar_2_acc->{$serovar}->{$asm_lvl},
                $serovar_count->{$serovar}
            );
        }
        if ( $asm_lvl =~ m/Contig/i ) {
            $serovar_count->{$serovar} = print_dl_metadata(
                $serovar, $asm_lvl,
                \$serovar_2_acc->{$serovar}->{$asm_lvl},
                $serovar_count->{$serovar}
            );
        }
        last if ( $serovar_count->{$serovar} == $serovar_limit );
    }
    print $Stderr $serovar_count->{$serovar}, "\t$serovar\n";
}

close $pdg_file;
close $tbl_file;
close $accs_cmp_fh;

#-------------------------------------------
# Main ends
#-------------------------------------------
# Routines begin
#-------------------------------------------

sub print_dl_metadata {
    my $serovar    = shift;
    my $asm_lvl    = shift;
    my $acc_sizes  = shift;
    my $curr_count = shift;

    $asm_lvl =~ s/.+?\_(.+)/$1/;

    foreach my $acc_size ( sort { $b <=> $a } keys %{$$acc_sizes} ) {
        foreach my $url ( @{ $$acc_sizes->{$acc_size} } ) {
            $curr_count++;
            my ( $final_acc, $genome_header ) =
              ( split( /\//, $url ) )[ 3 .. 4 ];
            print $Stdout "$serovar|$asm_lvl|$acc_size|$url\n";
            print $accs_cmp_fh "$final_acc\n";
            print $genome_headers_fh catfile( 'scaffold_genomes',
                $genome_header )
              . "\n";
            last if ( $curr_count == $serovar_limit );
        }
        last if ( $curr_count == $serovar_limit );
    }
    return $curr_count;
}

sub sort_asm_level {
    my $level = shift;

    $level =~ s/(Complete\s+Genome)/a\_$1/
      if ( $level =~ m/Complete\s+Genome/i );
    $level =~ s/(Chromosome)/b\_$1/ if ( $level =~ m/Chromosome/i );
    $level =~ s/(Scaffold)/c\_$1/   if ( $level =~ m/Scaffold/i );
    $level =~ s/(Contig)/d\_$1/     if ( $level =~ m/Contig/i );

    return $level;
}

sub not_empty {
    my $col = shift;

    if ( $col !~ m/^$/ ) {
        return 1;
    }
    else {
        return 0;
    }
}

__END__

=head1 SYNOPSIS

This script will take in a PDG metadata file, a C<.tbl> file and generate
the final list by B<I<waterfall>> priority. It prioritizes serotype 
coverage over SNP Cluster pariticipation.

See complete description:

  perldoc waterfall_per_computed_serotype.pl

    or

  waterfall_per_computed_serotype.pl --help

Examples:

  waterfall_per_computed_serotype.pl

=head1 DESCRIPTION

We will use the waterfall priority to retain
up to N number of serotype genomes per serotype
(by default up to N = 10 genomes).

The waterfall priority to collect genomes will be
given on the order of:

1. By the assembly status
    i.e Complete genome => Chromosome => Scaffold => Contig
    Then,
2. If up to X number of genomes are present on the same
    assembly level, Scaffold N50 >= Contig N50 size is
    used to sort the genomes
    Then,
3. If the same serovar genome is present on the same assembly
    level for same N50 size, then all of the genomes are    
    included as contiguous genome is preferred, even if the
    sequence composition is almost the same
    Then,
4. If both RefSeq and GenBank FTP Paths are present, RefSeq is
    preferred.

=head1 OPTIONS

=over 3

=item -p PDGXXXXX.XXXX.metadata.tsv

Absolute UNIX path pointing to the PDG metadata file.
Example: PDG000000002.2505

=item -t asm.tbl

Absolute UNIX path pointing to the file from the result
of the C<dl_pdg_data.py> script, which is the C<asm.tbl>
file.

=item --serocol <int> (Optional)

Column number (non 0-based index) of the PDG metadata file
by which the serotypes are collected. Default: 49

=item --complete_serotype_name (Optional)

Skip indexing serotypes when the serotype name in the column
number 49 (non 0-based) of PDG metadata file consists a "-". For example, if
an accession has a I<B<serotype=>> string as such in column
number 49 (non 0-based): C<"serotype=- 13:z4,z23:-","antigen_formula=13:z4,z23:-">
then, the indexing of that accession is skipped.
Default: False

=item --not_null_pdg_serovar (Optional)

Only index the B<I<computed_serotype>> column i.e. column number 49 (non 0-based)
if the B<I<serovar>> column is not C<NULL>.

=item -i <serotype name> (Optional)

Make sure the following serotype is included. Mention C<-i> multiple
times to include multiple serotypes.

=item -num <int> (Optional)

Number of genome accessions to be collected per serotype. Default: 10

=item --min_contig_size <int> (Optional)

Minimum contig size to consider a genome for indexing.
Default: 0

=item -op <str> (Optional)

Output prefix of the file for the accession list.

=back

=head1 AUTHOR

Kranti Konganti

=cut
