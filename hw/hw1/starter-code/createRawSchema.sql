create table Pub (k text, p text);
create table Field (k text, i text, p text, v text);
copy Pub from '/Users/haivanle/cse544-levh/hw/hw1/submission/pubFile.txt';
copy Field from '/Users/haivanle/cse544-levh/hw/hw1/submission/fieldFile.txt';
