function ouput=all_vowels_in_korean(type)
% type: 1. vowel, 2. consonant
if strcmp(type,'vowel')
ouput=cell(17,1);
ouput{1}='た';
ouput{2}='だ';
ouput{3}='ち';
ouput{4}='っ';
ouput{5}='づ';
ouput{6}='て';
ouput{7}='で';
ouput{8}='と';
ouput{9}='ど';
ouput{10}='に';
ouput{11}='ぬ';
ouput{12}='ね';
ouput{13}='は';
ouput{14}='ば';
ouput{15}='ぱ';
ouput{16}='ひ';
ouput{17}='び';
end
if strcmp(type,'consonant')
ouput=cell(19,1);
ouput{1}='ぁ';
ouput{2}='あ';
ouput{3}='い';
ouput{4}='ぇ';
ouput{5}='え';
ouput{6}='ぉ';
ouput{7}='け';
ouput{8}='げ';
ouput{9}='こ';
ouput{10}='さ';
ouput{11}='ざ';
ouput{12}='し';
ouput{13}='じ';
ouput{14}='す';
ouput{15}='ず';
ouput{16}='せ';
ouput{17}='ぜ';
ouput{18}='そ';
ouput{19}='ぞ';

end


