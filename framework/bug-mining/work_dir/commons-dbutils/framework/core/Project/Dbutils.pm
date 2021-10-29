#-------------------------------------------------------------------------------
# Copyright (c) 2014-2019 René Just, Darioush Jalali, and Defects4J contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

=pod

=head1 NAME

Project::Dbutils.pm -- L<Project> submodule for commons-dbutils.

=head1 DESCRIPTION

This module provides all project-specific configurations and subroutines for the
commons-dbutils project.

=cut
package Project::Dbutils;

use strict;
use warnings;

use Constants;
use Vcs::Git;

our @ISA = qw(Project);
my $PID  = "Dbutils";

sub new {
    @_ == 1 or die $ARG_ERROR;
    my ($class) = @_;

    my $name = "commons-dbutils";
    my $vcs  = Vcs::Git->new($PID,
                             "$REPO_DIR/$name.git",
                             "$PROJECTS_DIR/$PID/$BUGS_CSV_ACTIVE",
                             \&_post_checkout);

    return $class->SUPER::new($PID, $name, $vcs);
}

#
# Post-checkout tasks include, for instance, providing cached build files,
# fixing compilation errors, etc.
#
sub _post_checkout {
    my ($self, $rev_id, $work_dir) = @_;

    my $project_dir = "$PROJECTS_DIR/$self->{pid}";
    my $build_files_dir = "$PROJECTS_DIR/$PID/build_files/$rev_id";
    # Check whether a generated Ant build file exists
    if (-d "$build_files_dir") {
        if (-e "$work_dir/build.xml") {
            rename("$work_dir/build.xml", "$work_dir/build.xml.orig") or die "Cannot backup existing Ant build file: $!";
        }
        Utils::exec_cmd("cp $build_files_dir/* $work_dir", "Copy generated Ant build file") or die;
    }
}

#
# This subroutine is called by the bug-mining framework for each revision during
# the initialization of the project. Example uses are: converting and caching
# build files or other time-consuming tasks, whose results should be cached.
#
sub initialize_revision {
    my ($self, $rev_id, $vid) = @_;
    $self->SUPER::initialize_revision($rev_id);

    my $work_dir = $self->{prog_root};
    my $result = _default_layout($work_dir) // _maven_2_layout($work_dir) // _ant_layout($work_dir) // _maven_1_layout($work_dir);
    die "Unknown layout for revision: ${rev_id}" unless defined $result;

    $self->_add_to_layout_map($rev_id, $result->{src}, $result->{test});
    $self->_cache_layout_map(); # Force cache rebuild
}

#
# Distinguish between project layouts and determine src and test directories.
# Each _layout subroutine returns undef if it doesn't match the layout of the
# checked-out version. Otherwise, it returns a hash that provides the src and
# test directory, relative to the working directory.
#

#
# Default directory layouts, common in many (Maven) projects
#
sub _default_layout {
    @_ == 1 or die $ARG_ERROR;
    my ($dir) = @_;

    # Test for two common layouts
    my $result;
    if (-e "$dir/src/main/java" && -e "$dir/src/test/java"){
        $result = {src=>"src/main/java", test=>"src/test/java"};
    } elsif (-e "$dir/src/java" && -e "$dir/src/test"){
        $result = {src=>"src/java", test=>"src/test"};
    }
    return $result;
}

#
# Existing Ant build.xml and default.properties
#
sub _ant_layout {
    @_ == 1 or die $ARG_ERROR;
    my ($dir) = @_;
    my $src  = `grep "source.home" $dir/default.properties 2>/dev/null`;
    my $test = `grep "test.home" $dir/default.properties 2>/dev/null`;

    # Check whether this layout applies to the checked-out version
    return undef if ($src eq "" || $test eq "");

    $src =~ s/\s*source.home\s*=\s*(\S+)\s*/$1/;
    $test=~ s/\s*test.home\s*=\s*(\S+)\s*/$1/;

    return {src=>$src, test=>$test};
}

#
# Generated maven-build.xml and maven-build.properties
# (generated from an existing Maven 2 pom.xml using mvn ant:ant
#
sub _maven_2_layout {
    @_ == 1 or die $ARG_ERROR;
    my ($dir) = @_;
    my $src  = `grep "maven.build.srcDir.0" $dir/maven-build.properties 2>/dev/null`;
    my $test = `grep "maven.build.testDir.0" $dir/maven-build.properties 2>/dev/null`;

    return undef if ($src eq "" || $test eq "");

    $src =~ s/\s*maven\.build\.srcDir\.0\s*=\s*(\S+)\s*/$1/;
    $test=~ s/\s*maven\.build\.testDir\.0\s*=\s*(\S+)\s*/$1/;

    return {src=>$src, test=>$test};
}

#
# Existing Maven 1 project.xml.
#
sub _maven_1_layout {
    @_ == 1 or die $ARG_ERROR;
    my ($dir) = @_;
    my $src  = `grep "<sourceDirectory>" $dir/project.xml 2>/dev/null`;
    my $test = `grep "<unitTestSourceDirectory>" $dir/project.xml 2>/dev/null`;

    return undef if ($src eq "" || $test eq "");

    $src =~ s/\s*<sourceDirectory>\s*(\S+)\s*<.*/$1/s;
    $test=~ s/\s*<unitTestSourceDirectory>\s*(\S+)\s*<.*/$1/s;

    return {src=>$src, test=>$test};
}


1;
