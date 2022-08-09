function a = whyout(n)
%WHY    Provides succinct answers to almost any question.
%   WHY, by itself, provides a random answer.
%   WHY(N) provides the N-th answer.
%   Please embellish or modify this function to suit your own tastes.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 5.15.4.2 $  $Date: 2008/06/20 08:00:14 $

if nargin > 0
    dflt = RandStream.getDefaultStream();
    RandStream.setDefaultStream(RandStream('swb2712','seed',n));
end
switch fix(10*rand)
    case 0,        a = special_case;
    case {1 2 3},  a = phrase;
    otherwise,     a = sentence;
end
a(1) = upper(a(1));
% disp(a);
if nargin > 0
    RandStream.setDefaultStream(dflt);
end


%------------------

function a = special_case
switch fix(14*rand)
    case 0,   a = 'why not?';
    case 1,   a = 'don''t ask!';
    case 2,   a = 'it''s your karma.';
    case 3,   a = 'stupid question!';
    case 4,   a = 'how should I know?';
    case 5,   a = 'can you rephrase that?';
    case 6,   a = 'it should be obvious.';
    case 7,   a = 'the devil made me do it.';
    case 8,   a = 'the computer did it.';
    case 9,   a = 'the customer is always right.';
    case 10,  a = 'in the beginning, God created the heavens and the earth...';
    case 11,  a = 'abandon all hope, ye who enter here...';
    case 12,  a = 'only those elements time cannot wear were made before me.';
    otherwise,a = 'don''t you have something better to do?';
end

function a = phrase
switch fix(3*rand)
    case 0,    a = ['for the ' nouned_verb ' ' prepositional_phrase '.'];
    case 1,    a = ['to ' present_verb ' ' object '.'];
    otherwise, a = ['because ' sentence];
end

function a = preposition
switch fix(2*rand)
    case 0,    a = 'of';
    otherwise, a = 'from';
end

function a = prepositional_phrase
switch fix(3*rand)
    case 0,    a = [preposition ' ' article ' ' noun_phrase];
    case 1,    a = [preposition ' ' proper_noun];
    otherwise, a = [preposition ' ' accusative_pronoun];
end

function a = sentence
switch fix(0)
    case 0,    a = [subject ' ' predicate '.'];
end

function a = subject
switch fix(4*rand)
    case 0,    a = proper_noun;
    case 1,    a = nominative_pronoun;
    otherwise, a = [article ' ' noun_phrase];
end

function a = proper_noun
switch fix(43*rand) 
    case 0,    a = 'Cliff';
    case 1,    a = 'Mary';
    case 2,    a = 'William';
    case 3,    a = 'Joseph';
    case 4,    a = 'Peter';
    case 5,    a = 'Lauren';
    case 6,    a = 'Damian';
    case 7,    a = 'Barney';
    case 8,    a = 'Fred';
    case 9,    a = 'Marty';
    case 10,   a = 'Samuel';
    case 11,   a = 'Benjamin';
    case 12,   a = 'Christina';
    case 13,   a = 'Rebecca';
    case 14,   a = 'Joe';
    case 15,   a = 'Geraint';
    case 16,   a = 'Frank';
    case 17,   a = 'Gareth';
    case 18,   a = 'Karl';
    case 19,   a = 'Barack Obama';
    case 20,   a = 'George W Bush';
    case 21,   a = 'Steven Colbert';
    case 22,   a = 'Jon Stewart';
    case 23,   a = 'Matt';
    case 24,   a = 'Jon';
    case 25,   a = 'Eric';
    case 26,   a = 'Chris';
    case 27,   a = 'Barry';
    case 28,   a = 'Lyndsey';
    case 29,   a = 'James';
    case 30,   a = 'Captain Kirk';
    case 31,   a = 'Spock';
    case 32,   a = 'Skywalker';
    case 33,   a = 'Carl';
    case 34,   a = 'Albert';
    case 35,   a = 'Einstein';
    case 36,   a = 'Ray';
    case 37,   a = 'Cathy';
    case 38,   a = 'Eleanor';
    case 39,   a = 'Nikolaus';
    case 40,   a = 'Zoe';
    otherwise, a = 'Anonymous';
end

function a = noun_phrase
switch fix(4*rand)
    case 0,    a = noun;
    case 1,    a = [adjective_phrase ' ' noun_phrase];
    otherwise, a = [adjective_phrase ' ' noun];
end

function a = noun
switch fix(6*rand)
    case 0,    a = 'mathematician';
    case 1,    a = 'programmer';
    case 2,    a = 'system manager';
    case 3,    a = 'engineer';
    case 4,    a = 'hamster';
    case 5,    a = 'kid';
    case 5,    a = 'neuroscientist';
    case 5,    a = 'psychologist';
    case 5,    a = 'biologist';
    case 5,    a = 'taxi driver';
    case 5,    a = 'carpenter';
    case 5,    a = 'lecturer';
    case 5,    a = 'professor';
end

function a = nominative_pronoun
switch fix(5*rand)
    case 0,    a = 'I';
    case 1,    a = 'you';
    case 2,    a = 'he';
    case 3,    a = 'she';
    case 4,    a = 'they';
end

function a = accusative_pronoun
switch fix(4*rand)
    case 0,    a = 'me';
    case 1,    a = 'all';
    case 2,    a = 'her';
    case 3,    a = 'him';
end

function a = nouned_verb
switch fix(2*rand)
    case 0,    a = 'love';
    case 1,    a = 'approval';
end

function a = adjective_phrase
switch fix(6*rand)
    case {0 1 2},a = adjective;
    case {3 4},  a = [adjective_phrase ' and ' adjective_phrase];
    otherwise,   a = [adverb ' ' adjective];
end

function a = adverb
switch fix(3*rand)
    case 0,    a = 'very';
    case 1,    a = 'not very';
    otherwise, a = 'not excessively';
end

function a = adjective
switch fix(7*rand)
    case 0,    a = 'tall';
    case 1,    a = 'bald';
    case 2,    a = 'young';
    case 3,    a = 'smart';
    case 4,    a = 'rich';
    case 5,    a = 'terrified';
    otherwise, a = 'good';
end

function a = article
switch fix(3*rand)
    case 0,    a = 'the';
    case 1,    a = 'some';
    otherwise, a = 'a';
end

function a = predicate
switch fix(3*rand)
    case 0,    a = [transitive_verb ' ' object];
    otherwise, a = intransitive_verb;
end

function a = present_verb
switch fix(3*rand)
    case 0,    a = 'fool';
    case 1,    a = 'please';
    otherwise, a = 'satisfy';
end

function a = transitive_verb
switch fix(10*rand)
    case 0,    a = 'threatened';
    case 1,    a = 'told';
    case 2,    a = 'asked';
    case 3,    a = 'helped';
    otherwise, a = 'obeyed';
end

function a = intransitive_verb
switch fix(6*rand)
    case 0,    a = 'insisted on it';
    case 1,    a = 'suggested it';
    case 2,    a = 'told me to';
    case 3,    a = 'wanted it';
    case 4,    a = 'knew it was a good idea';
    otherwise, a = 'wanted it that way';
end

function a = object
switch fix(10*rand)
    case 0,    a = accusative_pronoun;
    otherwise, a = [article ' ' noun_phrase];
end
