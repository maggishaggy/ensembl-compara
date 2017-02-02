=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 NAME

Bio::EnsEMBL::Compara::RunnableDB::OrthologQM::CopyAlignmentTables

=cut

=head1 DESCRIPTION

Runs the $ENSEMBL_CVS_ROOT_DIR/ensembl-compara/scripts/pipeline/populate_new_database.pl script, dealing with missing parameters

=cut

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

package Bio::EnsEMBL::Compara::RunnableDB::OrthologQM::CopyAlignmentTables;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::RunnableDB::SystemCmd');


sub fetch_input {
    my $self = shift;

    my @cmd;
    push @cmd, $self->param_required('program');
    push @cmd, '--master', $self->param_required('master_db');
    push @cmd, '--new', $self->param('pipeline_db') if $self->param('pipeline_db');
    push @cmd, '--mlss', $self->param_required('mlss_id');
    push @cmd, '--reg-conf', $self->param('reg_conf') if $self->param('reg_conf');

    my $old_compara_db = ( $self->param('alt_aln_db') ) ? $self->param('alt_aln_db') : $self->param('compara_db');
    push @cmd, '--old', $old_compara_db;

    $self->warning(join(' ', @cmd));
    #@cmd = ('echo 1');
    $self->param('cmd', \@cmd);
}


1;