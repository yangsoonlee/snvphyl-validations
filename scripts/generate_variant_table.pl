#!/usr/bin/env perl
# Purpose
# Given a reference fasta file, number of genomes to generate, and number of positions generates a 'template' variant table to be filled in manually.

use warnings;
use strict;
use FindBin;

use lib $FindBin::Bin.'/lib';

use Bio::SeqIO;
use File::Basename;
use Getopt::Long;
use List::Util qw(shuffle);
use InvalidPositions;

my $usage =
"$0 --reference [reference.fasta] --num-genomes [number of genomes] --num-variants [number of positions] --random-seed [random seed] [--exclude-positions positions.tsv]\n".
"Parameters:\n".
"\t--reference:  A reference genome in FASTA format\n".
"\t--num-genomes: Number of genomes to include in the table\n".
"\t--num-substitutions: Number of substitution positions to generate in table\n".
"\t--num-insertions: Number of insertion positions to generate in table\n".
"\t--num-deletions: Number of deletion positions to generate in table\n".
"\t--random-seed: Random seed for generating mutations\n".
"\t--exclude-positions: A file of positions to exclude when generating random variants (if no parameter is passed select from all positions on reference).\n".
"Example:\n".
"$0 --reference reference.fasta --num-genomes 5 --num-variants 100 --random-seed 42 --exclude-positions repeats.tsv | sort -k 1,1 -k 2,2n > variants_table.tsv\n";

my $swap_table = {
'A' => ['T','G','C'],
'T' => ['A','G','C'],
'G' => ['A','T','C'],
'C' => ['A','G','T']};

my $reference_table;
my $reference_name;
my @sequence_names;
my $number_sequences;
my $positions_used = {};

sub get_mutated_base
{
	my ($base) = @_;
	return [shuffle @{$swap_table->{uc($base)}}]->[0];
}

# reads all reference sequences into a table structured like
# ref_id => ref_seq
sub read_reference_sequences
{
	my ($reference_file) = @_;
	my %sequence_table;

	my $ref_io = Bio::SeqIO->new(-file=>"< $reference_file",-format=>"fasta");
	die "could not parse reference file $reference_file\n$usage" if (not defined $ref_io);

	while (my $seq = $ref_io->next_seq)
	{
		$sequence_table{$seq->display_id} = $seq;
	}

	return \%sequence_table;
}

sub print_header_line
{
	my ($num_genomes,$reference_name) = @_;

	# print header line
	print "#Chromosome\tPosition\tStatus\tReference";
	# for each genome
	for (my $i = 0; $i < $num_genomes; $i++)
	{
		print "\t$reference_name-$i";
	}
	print "\n";
}

sub print_substitutions
{
	my ($base,$index) = @_;

	# every 2nd genome should be switched, the others left alone
	if ($index % 2 == 0)
	{
		print "\t".get_mutated_base($base);
	}
	else
	{
		print "\t$base";
	}
}

sub print_deletions
{
	my ($base,$index) = @_;

	# only print deletion for one genome
	if ($index == 0)
	{
		print "\t-";
	}
	# every 2nd genome should be switched, the others left alone
	elsif ($index % 2 == 0)
	{
		print "\t".get_mutated_base($base);
	}
	else
	{
		print "\t$base";
	}
}

sub print_insertions
{
	my ($base,$index) = @_;

	# only print insertion for one genome
	if ($index == 0)
	{
		my $newbase = get_mutated_base($base);
		print "\t${base}${newbase}";
	}
	# every 2nd genome should be switched, the others left alone
	elsif ($index % 2 == 0)
	{
		print "\t".get_mutated_base($base);
	}
	else
	{
		print "\t$base";
	}
}

sub get_unique_position
{
	my ($sequence_name,$pos,$sequence,$length_sequence);

	# generate unique positions
	do 
	{
		# select random sequence
		my $seq_num = int(rand($number_sequences));

		$sequence_name = $sequence_names[$seq_num];
		$sequence = $reference_table->{$sequence_name};
		$length_sequence = $sequence->length;

		# select random position
		$pos = int(rand($length_sequence));
	} while (exists $positions_used->{"${sequence_name}_${pos}"});
	$positions_used->{"${sequence_name}_${pos}"} = 1;

	my $seq_string = $sequence->seq;
	my $ref_base = substr($seq_string,$pos,1);

	return ($sequence_name,$pos,$ref_base);
}

############
### MAIN ###
############
my ($ref_file,$num_genomes,$num_substitutions,$num_deletions,$num_insertions,$random_seed, $excluded_positions_file);

if (!GetOptions('reference=s' => \$ref_file,
                'num-substitutions=i' => \$num_substitutions,
                'num-insertions=i' => \$num_insertions,
                'num-deletions=i' => \$num_deletions,
                'num-genomes=i' => \$num_genomes,
                'random-seed=i' => \$random_seed,
		'exclude-positions=s' => \$excluded_positions_file)) {
        die "Invalid option\n".$usage;
}

die "reference.fasta is not defined\n$usage" if (not defined $ref_file);
die "$ref_file does not exist\n$usage" if (not -e $ref_file);
die "number of genomes is not defined\n$usage" if (not defined $num_genomes);
die "number of genomes=$num_genomes is not valid\n$usage" if ($num_genomes !~ /^\d+$/);
die "number of substitutions=$num_substitutions is not valid\n$usage" if ($num_substitutions !~ /^\d+$/);
die "number of insertions=$num_insertions is not valid\n$usage" if ($num_insertions !~ /^\d+$/);
die "number of deletions=$num_deletions is not valid\n$usage" if ($num_deletions !~ /^\d+$/);

if (not defined $random_seed) {
	$random_seed = 42;
	warn "--random-seed not defined, defaulting to $random_seed\n";
}


srand($random_seed);


if (defined $excluded_positions_file) {
	print STDERR "Will exclude all positions in $excluded_positions_file\n";
	my $invalid_positions_parser = InvalidPositions->new;
	$positions_used = $invalid_positions_parser->read_invalid_positions($excluded_positions_file);
}


# read original reference sequences
$reference_table = read_reference_sequences($ref_file);
$reference_name = basename($ref_file, '.fasta');
@sequence_names = (keys %$reference_table);
$number_sequences = scalar(@sequence_names);

print_header_line($num_genomes,$reference_name);

# substitutions
for (my $pos_num = 0; $pos_num < $num_substitutions; $pos_num++)
{
	my ($sequence_name,$pos,$ref_base) = get_unique_position();

	# print variant line, +1 to position since positions start with 1, not 0
	print "$sequence_name\t".($pos+1)."\tvalid\t$ref_base";

	# for each genome to generate
	for (my $i = 0; $i < $num_genomes; $i++)
	{
		print_substitutions($ref_base,$i);
	}
	print "\n";
}

# deletions
for (my $pos_num = 0; $pos_num < $num_deletions; $pos_num++)
{
	my ($sequence_name,$pos,$ref_base) = get_unique_position();

	# print variant line, +1 to position since positions start with 1, not 0
	print "$sequence_name\t".($pos+1)."\tdeletion\t$ref_base";

	# for each genome to generate
	for (my $i = 0; $i < $num_genomes; $i++)
	{
		print_deletions($ref_base,$i);
	}
	print "\n";
}

# insertions
for (my $pos_num = 0; $pos_num < $num_insertions; $pos_num++)
{
	my ($sequence_name,$pos,$ref_base) = get_unique_position();

	# print variant line, +1 to position since positions start with 1, not 0
	print "$sequence_name\t".($pos+1)."\tinsertion\t$ref_base";

	# for each genome to generate
	for (my $i = 0; $i < $num_genomes; $i++)
	{
		print_insertions($ref_base,$i);
	}
	print "\n";
}
