#!/usr/bin/env perl

# Kranti Konganti
# 01/02/2024

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use File::Basename;
use File::Spec::Functions;

my $tbl               = {};
my $snp_2_serovar     = {};
my $acc_2_serovar     = {};
my $acc_2_target      = {};
my $snp_count         = {};
my $snp_2_acc         = {};
my $acc_2_snp         = {};
my $multi_cluster_acc = {};
my (
    $serovar_limit,          $serovar_or_type_col, $min_asm_size,
    $complete_serotype_name, $PDG_file,            $table_file,
    $not_null_pdg_serovar,   $snp_cluster,         $help,
    $out_prefix,             $acc_col,             $seronamecol,
    $target_acc_col
);
my @custom_serovars;

GetOptions(
    'help'                         => \$help,
    'pdg=s'                        => \$PDG_file,
    'tbl=s'                        => \$table_file,
    'snp=s'                        => \$snp_cluster,
    'min_contig_size=i'            => \$min_asm_size,
    'complete_serotype_name'       => \$complete_serotype_name,
    'serocol:i'                    => \$serovar_or_type_col,
    'seronamecol:i'                => \$seronamecol,
    'target_acc_col:i'             => \$target_acc_col,
    'acc_col:i'                    => \$acc_col,
    'not_null_pdg_serovar'         => \$not_null_pdg_serovar,
    'num_serotypes_per_serotype:i' => \$serovar_limit,
    'include_serovar=s'            => \@custom_serovars,
    'op=s'                         => \$out_prefix
) or pod2usage( -verbose => 2 );

if ( defined $help ) {
    pod2usage( -verbose => 2 );
}

if ( !defined $serovar_limit ) {
    $serovar_limit = 1;
}

if ( !defined $serovar_or_type_col ) {
    $serovar_or_type_col = 50;
}

if ( !defined $seronamecol ) {
    $seronamecol = 34;
}

if ( !defined $target_acc_col ) {
    $target_acc_col = 43;
}

if ( !defined $acc_col ) {
    $acc_col = 10;
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

pod2usage( -verbose => 2 ) if ( !$PDG_file || !$table_file || !$snp_cluster );

open( my $pdg_file, '<', $PDG_file )
  || die "\nCannot open PDG file $PDG_file: $!\n\n";
open( my $tbl_file, '<', $table_file )
  || die "\nCannot open tbl file $table_file: $!\n\n";
open( my $snp_cluster_file, '<', $snp_cluster )
  || die "\nCannot open $snp_cluster: $!\n\n";
open( my $acc_fh, '>', 'acc2serovar.txt' )
  || die "\nCannot open acc2serovar.txt: $!\n\n";
open( my $Stdout,      '>&', STDOUT ) || die "\nCannot pipe to STDOUT: $!\n\n";
open( my $Stderr,      '>&', STDERR ) || die "\nCannot pipe to STDERR: $!\n\n";
open( my $accs_snp_fh, '>',  $out_prefix . 'accs_snp.txt' )
  || die "\nCannnot open " . $out_prefix . "accs_snp.txt for writing: $!\n\n";
open( my $genome_headers_fh, '>', $out_prefix . 'mash_snp_genome_list.txt' )
  || die "\nCannnot open "
  . $out_prefix
  . "mash_snp_genome_list.txt for writing: $!\n\n";

my $pdg_release = basename( $PDG_file, ".metadata.tsv" );

while ( my $line = <$pdg_file> ) {
    chomp $line;
    next if ( $line =~ m/^\#/ );

    # Relevent columns (Perl index):
    #   10-1 = 9: asm_acc
    # 34 -1 = 33: serovar
    # 50 -1 = 49: computed serotype

    my @cols            = split( /\t/, $line );
    my $serovar_or_type = $cols[ $serovar_or_type_col - 1 ];
    my $acc             = $cols[ $acc_col - 1 ];
    my $serovar         = $cols[ $seronamecol - 1 ];
    my $target_acc      = $cols[ $target_acc_col - 1 ];

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

    # next
    #   if (
    #     (
    #            $serovar_or_type =~ m/serotype=\-\s+\-\:\-\:\-/
    #         || $serovar_or_type =~ m/antigen_formula=\-\:\-\:\-/
    #     )
    #   );

    if ( defined $not_null_pdg_serovar ) {
        $acc_2_serovar->{$acc} = $serovar_or_type,
          $acc_2_target->{$acc} = $target_acc,
          print $acc_fh "$acc\t$serovar_or_type\n"
          if ( $acc !~ m/NULL/
            && $serovar         !~ m/NULL/
            && $serovar_or_type !~ m/NULL/ );
    }
    else {
        $acc_2_serovar->{$acc} = $serovar_or_type,
          $acc_2_target->{$acc} = $target_acc,
          print $acc_fh "$acc\t$serovar_or_type\n"
          if ( $acc !~ m/NULL/ && $serovar_or_type !~ m/NULL/ );
    }

    # $snp_count->{$serovar_or_type} = 0;
}

#
# SNP to ACC
#

while ( my $line = <$snp_cluster_file> ) {
    chomp $line;
    my @cols = split( /\t/, $line );

    # Relevant columns
    # 0: SNP Cluster ID
    # 3: Genome Accession belonging to the cluster (RefSeq or GenBank)
    my $snp_clus_id = $cols[0];
    my $acc         = $cols[3];

    next if ( $acc =~ m/^NULL/ || $snp_clus_id =~ m/^PDS_acc/ );
    next if ( !exists $acc_2_serovar->{$acc} );
    push @{ $snp_2_acc->{$snp_clus_id} }, $acc;
    if ( exists $acc_2_snp->{$acc} ) {
        print $Stderr
          "\nGot a duplicate assembly accession. Cannot proceed!\n\n$line\n\n";
        exit 1;
    }
    $acc_2_snp->{$acc}         = $snp_clus_id;
    $snp_count->{$snp_clus_id} = 0;
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

    # my $idx0 = $acc_2_serovar->{$cols[0]};
    my $idx0 = $acc_2_snp->{$acc} if ( exists $acc_2_snp->{ $cols[0] } );

    if ( not_empty($acc) && defined $idx0 ) {
        my $fna_rel_loc =
            "$pdg_release/ncbi_dataset/data/$acc/"
          . $acc
          . '_scaffolded_genomic.fna.gz';

        if ( not_empty($scaffold_n50) ) {
            next if ( $scaffold_n50 <= $min_asm_size );
            push @{ $snp_2_serovar->{$idx0}->{ sort_asm_level($asm_lvl) }
                  ->{$scaffold_n50} }, "$acc_2_serovar->{$acc}|$fna_rel_loc";
        }
        elsif ( not_empty($contig_n50) ) {
            next if ( $contig_n50 <= $min_asm_size );
            push @{ $snp_2_serovar->{$idx0}->{ sort_asm_level($asm_lvl) }
                  ->{$contig_n50} }, "$acc_2_serovar->{$acc}|$fna_rel_loc";
        }
    }
}

foreach my $snp_cluster_id ( keys %$snp_2_acc ) {
    my $count = $snp_count->{$snp_cluster_id};
    foreach my $asm_lvl (
        sort { $a cmp $b }
        keys %{ $snp_2_serovar->{$snp_cluster_id} }
      )
    {
        if ( $asm_lvl =~ m/Complete\s+Genome/i ) {
            $count =
              print_dl_metadata( $asm_lvl,
                \$snp_2_serovar->{$snp_cluster_id}->{$asm_lvl},
                $count, $snp_cluster_id );
        }
        if ( $asm_lvl =~ m/Chromosome/i ) {
            $count =
              print_dl_metadata( $asm_lvl,
                \$snp_2_serovar->{$snp_cluster_id}->{$asm_lvl},
                $count, $snp_cluster_id );
        }
        if ( $asm_lvl =~ m/Scaffold/i ) {
            $count =
              print_dl_metadata( $asm_lvl,
                \$snp_2_serovar->{$snp_cluster_id}->{$asm_lvl},
                $count, $snp_cluster_id );
        }
        if ( $asm_lvl =~ m/Contig/i ) {
            $count =
              print_dl_metadata( $asm_lvl,
                \$snp_2_serovar->{$snp_cluster_id}->{$asm_lvl},
                $count, $snp_cluster_id );
        }
        printf $Stderr "%-17s  |  %s\n", $snp_cluster_id, $count
          if ( $count > 0 );
        last if ( $count >= $serovar_limit );
    }
}

close $pdg_file;
close $tbl_file;
close $snp_cluster_file;
close $acc_fh;
close $accs_snp_fh;

#-------------------------------------------
# Main ends
#-------------------------------------------
# Routines begin
#-------------------------------------------

sub print_dl_metadata {
    my $asm_lvl        = shift;
    my $acc_sizes      = shift;
    my $curr_count     = shift;
    my $snp_cluster_id = shift;

    $asm_lvl =~ s/.+?\_(.+)/$1/;

    foreach my $acc_size ( sort { $b <=> $a } keys %{$$acc_sizes} ) {
        foreach my $serovar_url ( @{ $$acc_sizes->{$acc_size} } ) {
            my ( $serovar, $url ) = split( /\|/, $serovar_url );
            return $curr_count if ( exists $multi_cluster_acc->{$url} );
            $multi_cluster_acc->{$url} = 1;
            $curr_count++;
            my ( $final_acc, $genome_header ) =
              ( split( /\//, $url ) )[ 3 .. 4 ];
            print $accs_snp_fh "$final_acc\n";
            print $genome_headers_fh catfile( 'scaffold_genomes',
                $genome_header )
              . "\n";
            print $Stdout "$serovar|$asm_lvl|$acc_size|$url|$snp_cluster_id\n"
              if ( $curr_count > 0 );
        }
        last if ( $curr_count >= $serovar_limit );
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
the final list by B<I<waterfall>> priority.

See complete description:

  perldoc waterfall_per_snp_cluster.pl

    or

  waterfall_per_snp_cluster.pl --help

Examples:

  waterfall_per_snp_cluster.pl

=head1 DESCRIPTION

We will retain up to N number of genome accessions per SNP cluster.
It prioritizes SNP Cluster participation over serotype coverage.
Which N genomes are selected depends on (in order):

1. Genome assembly level, whose priority is

    a: Complete Genome
    b: Chromosome
    c: Scaffold
    d: Contig

2. If the genomes are of same assembly level, then
    scaffold N50 followed by contig N50 is chosen.

3. If the scaffold or contig N50 is same, then all
    of them are included

=head1 OPTIONS

=over 3

=item -p PDGXXXXX.XXXX.metadata.tsv

Absolute UNIX path pointing to the PDG metadata file.
Example: PDG000000002.2505.metadata.tsv

=item -t asm.tbl

Absolute UNIX path pointing to the file from the result
of the C<dl_pdg_data.py> script, which is the C<asm.tbl>
file.

=item -snp PDGXXXXXXX.XXXX.reference_target.cluster_list.tsv

Absolute UNIX path pointing to the SNP Cluster metadata file.
Examples: PDG000000002.2505.reference_target.cluster_list.tsv

=item --serocol <int> (Optional)

Column number (non 0-based index) of the PDG metadata file
by which the serotypes are collected
(column name: "computed_types"). Default: 50

=item --seronamecol <int> (Optional)

Column number (non 0-based index) of the PDG metadata file
whose column name is "serovar". Default: 34

=item --acc_col <int> (Optional)

Column number (non 0-based index) of the PDG metadata file
whose column name is "acc". Default: 10

=item --target_acc_col <int> (Optional)

Column number (non 0-based index) of the PDG metadata file
whose column name is "target_acc". Default: 43

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

Number of genome accessions per SNP Cluster. Default: 1

=back

=head1 AUTHOR

Kranti Konganti

=cut
