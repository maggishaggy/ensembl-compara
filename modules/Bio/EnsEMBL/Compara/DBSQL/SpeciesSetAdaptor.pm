package Bio::EnsEMBL::Compara::DBSQL::SpeciesSetAdaptor;

use vars qw(@ISA);
use strict;

use Bio::EnsEMBL::DBSQL::BaseAdaptor;
use Bio::EnsEMBL::Compara::SpeciesSet;
use Bio::EnsEMBL::Utils::Exception;

@ISA = qw(Bio::EnsEMBL::DBSQL::BaseAdaptor);

=head2 new

  Arg [1]    : list of args to super class constructor
  Example    : $ga_a = new Bio::EnsEMBL::Compara::SpeciesSetAdaptor($dbobj);
  Description: Creates a new SpeciesSetAdaptor.  This
               class should be instantiated through the get method on the 
               DBAdaptor rather than calling this method directly.
  Returntype : none
  Exceptions : none
  Caller     : Bio::EnsEMBL::DBSQL::DBConnection
  Status     : Stable

=cut

sub new {
  my $class = shift;

  my $self = $class->SUPER::new(@_);

  return $self;
}

sub fetch_by_dbID {
  my ($self, $dbID) = @_;
  my $species_set; # returned object

  my $sql = qq{
          SELECT
              species_set_id,
              genome_db_id
          FROM
              species_set
          WHERE
              species_set_id = ?
      };

  my $sth = $self->prepare($sql);
  $sth->execute($dbID);
  my ($species_set_id,$genome_db_id);
  $sth->bind_columns(\$species_set_id,\$genome_db_id);
  my $genome_dbs;
  while ($sth->fetch) {
    my $genome_db = $self->db->get_GenomeDBAdaptor->fetch_by_dbID($genome_db_id);
    push(@$genome_dbs, $genome_db) if (defined($genome_db));
  }
  $sth->finish();

  ## Create the object
  $species_set = new Bio::EnsEMBL::Compara::SpeciesSet
    (-adaptor => $self,
     -dbID => $dbID,
     -genome_dbs => $genome_dbs);
  $self->_load_tagvalues($species_set);

  return $species_set;
}


sub fetch_by_tag_value {
  my ($self, $tag, $value) = @_;
  my $species_set; # returned object

  my $sql = qq{
          SELECT
              species_set_id
          FROM
              species_set_tag
          WHERE
              tag = ?
          AND
              value = ?
      };

  my $sth = $self->prepare($sql);
  $sth->execute($tag,$value);
  my $species_set_id;
  $sth->bind_columns(\$species_set_id);
  $sth->fetch;
  $sth->finish;

  ## Create the object
  if (defined($species_set_id)) {
    $species_set = $self->fetch_by_dbID($species_set_id);
  }

  return $species_set;

}


sub fetch_all_by_GenomeDBs {
  my ($self, $genome_dbs) = @_;
  my $species_set_id;

  my $genome_db_ids;
  foreach my $genome_db (@$genome_dbs) {
    throw "[$genome_db] must be a Bio::EnsEMBL::Compara::GenomeDB object or the corresponding dbID"
        unless ($genome_db and $genome_db->isa("Bio::EnsEMBL::Compara::GenomeDB"));
    my $genome_db_id = $genome_db->dbID;
    throw "[$genome_db] must have a dbID" if (!$genome_db_id);
    push (@$genome_db_ids, $genome_db_id);
  }

  if (!defined($genome_db_ids)) {
    return undef;
  }

  my $sql = qq{
          SELECT
            species_set_id,
            COUNT(*) as count
          FROM
            species_set
          WHERE
            genome_db_id in (}.join(",", @$genome_db_ids).qq{)
          GROUP BY species_set_id
          HAVING count = }.(scalar(@$genome_db_ids));
  my $sth = $self->prepare($sql);
  $sth->execute();
  my $all_rows = $sth->fetchall_arrayref();
  $sth->finish();

  if (!@$all_rows) {
    return undef;
  }
  my $species_set_ids = [map {$_->[0]} @$all_rows];

  ## Keep only the species_set which does not contain any other genome_db_id
  $sql = qq{
          SELECT
            species_set_id,
            COUNT(*) as count
          FROM
            species_set
          WHERE
            species_set_id in (}.join(",", @$species_set_ids).qq{)
          GROUP BY species_set_id
          HAVING count = }.(scalar(@$genome_db_ids));
  $sth = $self->prepare($sql);
  $sth->execute();

  $all_rows = $sth->fetchall_arrayref();

  $sth->finish();

  if (!@$all_rows) {
    return undef;
  } elsif (@$all_rows > 1) {
    warning("Several species_set_ids have been found for genome_db_ids (".
        join(",", @$genome_db_ids)."): ".join(",", map {$_->[0]} @$all_rows));
  }
  $species_set_id = $all_rows->[0]->[0];

  my $species_set = $self->fetch_by_dbID($species_set_id);

  return $species_set;
}

sub fetch_all {
  my $self = shift;
  my $species_sets = [];

  my $sql = qq{
          SELECT
              distinct species_set_id
          FROM
              species_set
      };

  my $sth = $self->prepare($sql);
  $sth->execute();
  my ($species_set_id);
  $sth->bind_columns(\$species_set_id);
  while ($sth->fetch) {
    my $species_set = $self->fetch_by_dbID($species_set_id);
    push(@$species_sets, $species_set);
  }
  $sth->finish();

  return $species_sets;
}

###################################
#
# tagging 
#
###################################

sub _load_tagvalues {
  my $self = shift;
  my $species_set = shift;

  unless($species_set->isa('Bio::EnsEMBL::Compara::SpeciesSet')) {
    throw("set arg must be a [Bio::EnsEMBL::Compara::SpeciesSet] not a $species_set");
  }

  my $sth = $self->prepare("SELECT tag,value from species_set_tag where species_set_id=?");
  $sth->execute($species_set->dbID);
  while (my ($tag, $value) = $sth->fetchrow_array()) {
    $species_set->add_tag($tag,$value);
  }
  $sth->finish;
}


sub _store_tagvalue {
  my $self = shift;
  my $species_set_id = shift;
  my $tag = shift;
  my $value = shift;

  $value="" unless(defined($value));

  my $sql = "INSERT ignore into species_set_tag (species_set_id,tag) values ($species_set_id,\"$tag\")";
  #print("$sql\n");
  $self->dbc->do($sql);

  $sql = "UPDATE species_set_tag set value=\"$value\" where species_set_id=$species_set_id and tag=\"$tag\"";
  #print("$sql\n");
  $self->dbc->do($sql);
}


1;
