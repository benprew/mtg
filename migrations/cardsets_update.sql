insert into cardsets (name, cardset_import_id) select set_name, upper(set_name) from cards group by set_name;

update cards c, cardsets cs set c.cardset_id = cs.id where cs.name = c.set_name;

insert into cardsets (name, cardset_import_id) values ('Scars of Mirrodin', 'SCARS_OF_MIRRODIN');

