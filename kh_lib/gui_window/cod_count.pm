package gui_window::cod_count;
use base qw(gui_window);

use gui_hlist;
use gui_widget::tani;
use kh_cod;

use strict;
use Jcode;
use Tk;
use Tk::LabFrame;
use Tk::HList;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	#$win->focus;
	$win->title($self->gui_jchar('�����ǥ��󥰡�ñ�㽸��'));
	
	#------------------------#
	#   ���ץ����������ʬ   #

	my $lf = $win->LabFrame(
		-label => 'Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');

	# �롼�롦�ե�����
	my %pack4cod = (
			-anchor => 'w',
	);
	$self->{codf_obj} = gui_widget::codf->open(
		parent => $lf,
		pack   => \%pack4cod,
	);

	# �����ǥ���ñ��
	my $f2 = $lf->Frame()->pack(-expand => 'y', -fill => 'x', -pady => 3);
	$f2->Label(
		-text => $self->gui_jchar('�����ǥ���ñ�̡�'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');
	my %pack = (
			-anchor => 'e',
			-pady   => 1,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f2,
		pack   => \%pack
	);

	$f2->Button(
		-text    => $self->gui_jchar('����'),
		-font    => "TKFN",
		-width   => 8,
		-command => sub{ $mw->after(10,sub{$self->_calc;});}
	)->pack( -side => 'right',-pady => 2);

	#------------------#
	#   ���ɽ����ʬ   #

	my $rf = $win->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'yes',-anchor => 'n');

	my $hlist_fra = $rf->Frame()->pack(-expand => 'y', -fill => 'both');
	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'black',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => $self->gui_jchar('������̾'));
	$lis->header('create',1,-text => $self->gui_jchar('����'));
	$lis->header('create',2,-text => $self->gui_jchar('�ѡ������'));

	my $label = $rf->Label(
		-text       => 'Ready.',
		-font       => "TKFN",
		-foreground => 'blue'
	)->pack(-side => 'left');

	$rf->Button(
		-text => $self->gui_jchar('���ԡ�'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'right', -anchor => 'e', -pady => 1);

	$self->{label} = $label;
	$self->{list}  = $lis;
	return $self;
}

#------------------#
#   ���ץ롼����   #

sub _calc{
	my $self = shift;
	
	$self->label->configure(
		-text => 'Counting...',
		-foreground => 'red'
	);
	$self->list->delete('all');
	$self->win_obj->update;
	
	my $tani = $self->tani;
	my $codf = $self->cfile;
	
	unless (-e $codf){
		my $win = $self->win_obj;
		gui_errormsg->open(
			msg => "�����ǥ��󥰡��롼�롦�ե����뤬���򤵤�Ƥ��ޤ���",
			window => \$win,
			type => 'msg',
		);
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return;
	}
	
	my $result;
	unless ($result = kh_cod::func->read_file($codf)){
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return 0;
	}
	$result = $result->count($tani);
	unless ($result){
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return;
	}


	my $right_style = $self->list->ItemStyle(
		'text',
		-font => "TKFN",
		-anchor => 'e',
		-background => 'white'
	);
	
	my $row = 0;
	foreach my $i (@{$result}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate(
			$row,
			0,
			-text  => $self->gui_jchar($i->[0],'euc'),
		);
		$self->list->itemCreate(
			$row,
			1,
			-text => $i->[1],
			-style => $right_style
		);
		$self->list->itemCreate(
			$row,
			2,
			-text => $i->[2],
			-style => $right_style
		);
		++$row;
	}

	$self->label->configure(
		-text => 'Ready.',
		-foreground => 'blue'
	);
	$self->win_obj->update;

}



#--------------#
#   ��������   #

sub cfile{
	my $self = shift;
	$self->{codf_obj}->cfile;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}


sub list{
	my $self = shift;
	return $self->{list};
}
sub label{
	my $self = shift;
	return $self->{label};
}
sub win_name{
	return 'w_cod_count';
}


1;