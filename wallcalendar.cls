
% wallcalendar.cls; Don't edit this file. Edit wallcalendar-code.org with emacs org-mode and call 'org-babel-tangle'.
%
% Wall Calendar
%
% A wall calendar document class with custom layouts and support for internationalization.
%
% (c) Gambhiro Bhikkhu, 2016
% gambhiro.bhikkhu.85@gmail.com
%
% LPPL LaTeX Public Project License

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{wallcalendar}[2016/11/21 v1.0 A wall calendar class with custom layouts and support for internationalization.]

\RequirePackage{pgfopts}
\RequirePackage{calc}

\newlength\calPaperWidth
\newlength\calPaperHeight
\newlength\@wall@leftMargin
\newlength\@wall@rightMargin
\newlength\@wall@topMargin
\newlength\@wall@bottomMargin

\def\@wall@eventsCsv{}
\def\@wall@markDefaultsCsv{}
\def\@wall@translationsInputFile{}

\newcommand*\theMonthName{}

\newif\ifvarnishmask
\newif\ifshowframe
\newif\iftranslationsAutoload

\pgfkeys{
  /wall/.is family, /wall,
  defaults/.style = {
    year = \the\year,
    altyear = \empty,
    language = english,
    translationsAutoload = true,
    imageFolder = {./src-images},
    choralOctavoPaper,
    hMargin = 17mm,
    topMargin = 20.5mm,
    bottomMargin = 10mm,
  },
  year/.store in = \CalendarYear,
  year/.initial = \the\year,
  altyear/.store in = \CalendarAltYear,
  altyear/.initial = \empty,
  language/.store in = \@wall@calendarLanguage,
  translationsInputFile/.store in = \@wall@translationsInputFile,
  translationsInputFile/.initial = {},
  translationsAutoload/.is if = translationsAutoload,
  eventsCsv/.store in = \@wall@eventsCsv,
  eventsCsv/.initial = {},
  markDefaultsCsv/.store in = \@wall@markDefaultsCsv,
  markDefaultsCsv/.initial = {},
  varnishmask/.is if = varnishmask,
  showframe/.is if = showframe,
  imageFolder/.store in = \@wall@imageFolder,
  paperWidth/.code = {\setlength{\calPaperWidth}{#1}},
  paperHeight/.code = {\setlength{\calPaperHeight}{#1}},
  hMargin/.code = {\setlength{\@wall@leftMargin}{#1}%
                   \setlength{\@wall@rightMargin}{#1}},
  leftMargin/.code = {\setlength{\@wall@leftMargin}{#1}},
  rightMargin/.code = {\setlength{\@wall@rightMargin}{#1}},
  topMargin/.code = {\setlength{\@wall@topMargin}{#1}},
  bottomMargin/.code = {\setlength{\@wall@bottomMargin}{#1}},
  % Paper sizes
  choralOctavoPaper/.style = {paperWidth = 6.75in, paperHeight = 10.5in},
  a5Paper/.style = {paperWidth = 148mm, paperHeight = 210mm},% r = 1.4142 = sqrt(2)
  prevPaper/.style = {paperWidth = 170mm, paperHeight = 250mm},% r = 1.4705
}

% Debug with: \wlog{YEA: \the\@wall@bottomMargin}

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{memoir}
}

\pgfkeys{/wall, defaults}
\ProcessPgfOptions{/wall}
\ProcessOptions\relax

\LoadClass[11pt,oneside]{memoir}

\newlength\@tmp@a
\newlength\@tmp@b
\newlength\@tmp@c
\newlength\@tmp@width
\newlength\@tmp@height

\RequirePackage{nag}
%\RequirePackage{textcomp}
\RequirePackage[cmyk]{xcolor}
\RequirePackage{graphicx}
\DeclareGraphicsExtensions{.pdf,.png,.jpg}
\graphicspath{{\@wall@imageFolder}}

\RequirePackage{eso-pic}
\RequirePackage{ccicons}
\RequirePackage{multicol}

\RequirePackage{pdftexcmds}
\RequirePackage{etoolbox}
\RequirePackage{luacode}

\RequirePackage{xcoffins}
%\RequirePackage{xstring}
%\RequirePackage{stringstrings}

\RequirePackage{tikz}
\usetikzlibrary{calendar}
\usetikzlibrary{positioning}
\usetikzlibrary{fit}
\usetikzlibrary{shapes.geometric}

\definecolor{textbody}{gray}{0.15}

% pantone 1245C, RGB 191,145,12 HEX: #BF910C
% pantone 1255C, CMYK 0,27.5,100,34
\definecolor{gold}{cmyk}{0,0.275,1,0.34}
\definecolor{darkgold}{cmyk}{0.27,0.53,1,0.09}
%\definecolor{orangegold}{cmyk}{0,0.31,0.89,0}
\colorlet{orangegold}{darkgold}

\colorlet{gridcolor}{black!30}
\colorlet{weekday}{black}
\colorlet{weekend}{black!50}
\colorlet{mooncolor}{textbody}

\definecolor{datenum}{gray}{0.3}
\definecolor{plannerdatenum}{gray}{0.15}
\definecolor{quote}{gray}{0.3}
\definecolor{notes}{gray}{0.3}

\colorlet{photo-frame}{blue}
\colorlet{quote-frame}{red}
\colorlet{heading-frame}{brown}
\colorlet{calendar-frame}{orange}
\colorlet{events-frame}{green}

\ifshowframe
  \colorlet{calendarbg}{black!50}
\else
  \colorlet{calendarbg}{white}
\fi

\ifshowtrims
  \setstocksize{\calPaperHeight + 35mm}{\calPaperWidth + 35mm}
  \setlength{\paperheight}{\calPaperHeight}
  \setlength{\paperwidth}{\calPaperWidth}
  \trimXmarks
  \trimLmarks
  \quarkmarks
  \settrims{0.5\stockheight - 0.5\paperheight}{0.5\stockwidth - 0.5\paperwidth}
  \settrimmedsize{\calPaperHeight}{\calPaperWidth}{*}
\else\relax
  \setstocksize{\calPaperHeight}{\calPaperWidth}
  \settrims{0pt}{0pt}
  \settrimmedsize{\stockheight}{\stockwidth}{*}
\fi

%\settypeblocksize{\stockheight}{\stockwidth}{*}
% TODO: calculate margins by ratios to paper size
\setlrmarginsandblock{\@wall@leftMargin}{\@wall@rightMargin}{*}
\setulmarginsandblock{\@wall@topMargin}{\@wall@bottomMargin}{*}
\setheadfoot{0pt}{0pt}
\setheaderspaces{0pt}{*}{*}

\checkandfixthelayout% This will typeout values in pt.
\settypeoutlayoutunit{mm}% It is useful to see layout values in mm too.
\typeoutlayout

\def\@wall@fontSize{11}
\def\@wall@lineHeight{13.6}

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize\@wall@fontSize\@wall@lineHeight
  \abovedisplayskip 11\p@ \@plus3\p@ \@minus6\p@
  \abovedisplayshortskip \z@ \@plus3\p@
  \belowdisplayshortskip 6.5\p@ \@plus3.5\p@ \@minus3\p@
  \belowdisplayskip \abovedisplayskip
  \color{textbody}
  \let\@listi\@listI}
\normalsize

\setlength{\vgap}{1.5em}
\setlength{\vindent}{\vgap}
\setlength{\vleftmargin}{2em}

\setlength{\parskip}{0pt}
\setlength{\parindent}{0pt}

\setlength{\fboxsep}{0pt}

\definecolor{varnishmask}{gray}{0}

% http://tex.stackexchange.com/a/59571/831
\newcommand*{\strcmpblank}[3]{%
  \ifnum\pdf@strcmp{#1}{}=\z@ #2\else #3\fi
}

\newcommand\@placeholder@pre[1]{%
  \settowidth{\@tmp@width}{#1}%
  \settototalheight{\@tmp@height}{#1}%
  \def\@spacer{\rule{\@tmp@width}{0pt}\rule{0pt}{\@tmp@height}}%
}

\newcommand\placeholder[3][]{%
  \ifvarnishmask%
    \ifstrequal{#2}{hasvarnish}{%
      \@placeholder@pre{#3}%
      \tikz\node[fill=varnishmask, inner sep=0pt]{\@spacer};%
    }{}%
  \else%
    \ifshowframe%
      \@placeholder@pre{#3}%
      \tikz\node[inner sep=0pt, opacity=0.6, #1]{\@spacer};%
    \else%
      #3%
    \fi%
  \fi%
}

\def\@wall@photo@putPhoto#1{#1}
\def\@wall@photo@setYOffset{}

\pgfkeys{
  /put photo/.is family, /put photo,
  simple/.code = {%
    \def\@wall@photo@putPhoto##1{%
      \includegraphics{##1}%
    }%
    \def\@wall@photo@setYOffset{}%
  },
  full page/.code = {%
    \def\@wall@photo@putPhoto##1{%
      \includegraphics[%
        keepaspectratio,%
        width={\calPaperWidth + 2\@t@bleed},%
      ]{##1}%
    }%
    \def\@wall@photo@setYOffset{}%
  },
  full width above calendar/.code = {%
    \def\@wall@photo@putPhoto##1{%
      \includegraphics[%
        keepaspectratio,%
        width={\calPaperWidth + 2\@t@bleed},%
      ]{##1}%
    }%
    \def\@wall@photo@setYOffset{%
      \setlength{\@t@yOffset}{\@t@calendar@height + \@t@bleed + 1pt}%
    }%
  },
  full width/.code = {%
    \def\@wall@photo@putPhoto##1{%
      \includegraphics[%
        keepaspectratio,%
        width={\calPaperWidth + 2\@t@bleed},%
      ]{##1}%
    }%
    \def\@wall@photo@setYOffset{%
      \setlength{\@t@yOffset}{\@t@calendar@height + \@t@bleed}%
    }%
  },
}

\pgfkeys{
  /Photo/.is family, /Photo,
  init/.style = {
    defaults/.style = {file = {}, thumbFile = {}, caption = {}, bleed = 0pt, xOffset=0pt, yOffset=0pt},
    file/.initial = {},
    thumbFile/.initial = {},
    caption/.initial = {},
    bleed/.initial = 0pt,
    xOffset/.initial = 0pt,
    yOffset/.initial = 0pt,
  },
}

\pgfkeys{
  /Quote/.is family, /Quote,
  init/.style = {
    defaults/.style = {position=center, text={}, xOffset=0pt, yOffset=0pt},
    position/.initial = {},
    text/.initial = {},
    xOffset/.initial = 0pt,
    yOffset/.initial = 0pt,
  },
}

\pgfkeys{
  /Calendar/.is family, /Calendar,
  init/.style = {
    defaults/.style = {bg/.style={opacity=0.5}},
    bg/.style = {},
    minimum height/.initial = {},
  },
}

\pgfkeys{
  /Events/.is family, /Events,
  init/.style = {
    defaults/.style = {day code = {}, marks = {}, text = {}},
    day code/.initial = {},
    marks/.initial = {},
    text/.initial = {},
  },
}

\pgfkeys{
  /Txt/.is family, /Txt,
  init/.style = {
    defaults/.style = {text = {}},
    text/.initial = {},
  },
}

\def\eIdx{}
\def\eMaxIdx{}
\def\eMark{}
\def\eIsoDate{}
\def\eYear{}
\def\eMonth{}
\def\eMonthShort{}
\def\eDay{}
\def\eDayText{}
\def\eNote{}

\pgfkeys{
  /parseMonthEvents/.is family, /parseMonthEvents,
  month/.initial = {},
  filter pred/.initial = nil,
  format func/.initial = nil,
  format cmd/.initial = {},
  events csv/.initial = {},
  mark defaults csv/.initial = {},
  min events/.initial = {},
  defaults/.style = {
    month = \theMonthName,
    filter pred = nil,
    format func = nil,
    format cmd = {\textsuperscript{\eIdx}~\eMonthShort~\eDay:~\eNote\par},
    events csv = \@wall@eventsCsv,
    mark defaults csv = \@wall@markDefaultsCsv,
    min events = nil,
  },
}

\pgfkeys{
  /parseYearEvents/.is family, /parseYearEvents,
  year/.initial = {},
  filter pred/.initial = nil,
  format func/.initial = nil,
  format cmd/.initial = {},
  events csv/.initial = {},
  mark defaults csv/.initial = {},
  min events/.initial = {},
  defaults/.style = {
    year = \CalendarYear,
    filter pred = nil,
    format func = nil,
    format cmd = {\textsuperscript{\eIdx}~\eMonthShort~\eDay:~\eNote\ifnumless{\eIdx}{\eMaxIdx}{,\space}{.}},
    events csv = \@wall@eventsCsv,
    mark defaults csv = \@wall@markDefaultsCsv,
    min events = nil,
  },
}

\newcommand\StarMark{*}

\newcommand\NoteStarMark{*}

\newlength\@wall@starHeight

% Measure the star's height here, so that we are measuring with the current typeface.
\newcommand\KiteMark{%
\setlength{\@wall@starHeight}{\totalheightof{*}}%
\begin{tikzpicture}
  \node (box) [
    rectangle, minimum height=\@wall@starHeight, minimum width=3.4pt,
    inner sep=0pt, line width=0pt,
  ] {};
  \node[
    kite, draw, textbody, fill=textbody,
    scale=0.15, kite vertex angles=60,
    above=0pt of box.north, anchor=north,
  ] {};%
\end{tikzpicture}%
}

% Same as \KiteMark but with scale=0.2
\newcommand\NoteKiteMark{\raisebox{1pt}{%
\setlength{\@wall@starHeight}{\totalheightof{*}}%
\begin{tikzpicture}
  \node (box) [
    rectangle, minimum height=\@wall@starHeight, minimum width=3.4pt,
    inner sep=0pt, line width=0pt,
  ] {};
  \node[
    kite, draw, textbody, fill=textbody,
    scale=0.2, kite vertex angles=60,
    above=0pt of box.north, anchor=north,
  ] {};%
\end{tikzpicture}%
}}

\tikzstyle{moon circle}=[
  circle,
  inner sep=0pt,
  line width=0pt,
  minimum height=8pt,
]

\newlength\@wall@moonRaise
\setlength{\@wall@moonRaise}{-0.7pt}

\newcommand\NewMoon{%
\raisebox{\@wall@moonRaise}{%
  \tikz\node[moon circle, fill=mooncolor] {};%
}}

\newcommand\FullMoon{%
\raisebox{\@wall@moonRaise}{%
  \tikz\node[moon circle, draw, mooncolor, line width=0.3pt] {};%
}}

\newcommand\FirstQuarter{%
\raisebox{\@wall@moonRaise}{%
\begin{tikzpicture}
\node [moon circle, name=waxing] {};
\path[fill=mooncolor]
  (waxing.north) --
  (waxing.south) to[out=-180,in=-90]
  (waxing.west) to[out=90,in=-180]
  (waxing.north);
\end{tikzpicture}%
}}

\newcommand\LastQuarter{%
\raisebox{\@wall@moonRaise}{%
\begin{tikzpicture}
\node [moon circle, name=waning] {};
\path[fill=mooncolor]
  (waning.north) --
  (waning.south) to[out=0,in=-90]
  (waning.east) to[out=90,in=0]
  (waning.north);
\end{tikzpicture}%
}}

\newcommand\SetPhoto[2][]{%
  \pgfkeys{%
    /Photo/#2/.is family, /Photo/#2,
    /Photo/init,
    defaults, file={#2},
    #1%
  }%
}

\newcommand\SetCalendar[2][]{%
  \pgfkeys{%
    /Calendar/#2/.is family, /Calendar/#2,
    /Calendar/init,
    defaults,
    #1%
  }%
}

\newcommand\SetQuote[3][]{%
  \pgfkeys{%
    /Quote/#2/.is family, /Quote/#2,
    /Quote/init,
    defaults, text={#3},
    #1%
  }%
}

\newcommand\SetEvents[4][]{%
  \pgfkeys{%
    /Events/#2/.is family, /Events/#2,
    /Events/init,
    defaults, marks={#3}, text={#4},
    #1%
  }%
}

\pgfkeys{
  /MonthPage/.is family, /MonthPage,
  layout/.style = {layout handlers/#1/.get = \@wall@month@doLayout},
  put photo/.style = {/put photo/#1},
  defaults/.style = {layout = small landscape, put photo = simple},
  layout handlers/.cd,
    full page/.initial = \@wall@fullPageLayout,
    small landscape/.initial = \@wall@smallLandscapeLayout,
}

\newcommand\MonthPage[2][]{%
  \pgfkeys{/MonthPage, defaults, #1}%
  \@wall@month@doLayout{#2}%
}

\newcommand\SetTxt[2]{%
  \pgfkeys{%
    /Txt/#1/.is family, /Txt/#1,
    /Txt/init,
    defaults, text={#2},
  }%
}

\newcommand\txt[1]{%
\pgfkeys{/Txt/#1/text/.get=\@val}%
\@val%
}

\def\@t@monthName{}
\def\@t@eventsCsv{}
\def\@t@markDefaultsCsv{}
\def\@t@filterPred{}
\def\@t@formatFunc{}
\def\@t@formatCmd{}
\def\@t@minEvents{}

\newcommand\monthMarkFmt{\color{textbody}}

\newcommand\symbolSpace{\thinspace}
\newcommand\symbolSeparator{,\symbolSpace}

% #1 = option keys
\newcommand*\parseMonthEvents[1][]{%
\pgfkeys{/parseMonthEvents, defaults, #1,
  month/.get=\@t@monthName,
  filter pred/.get=\@t@filterPred,
  format func/.get=\@t@formatFunc,
  format cmd/.get=\@t@formatCmd,
  events csv/.get=\@t@eventsCsv,
  mark defaults csv/.get=\@t@markDefaultsCsv,
  min events/.get=\@t@minEvents,
}%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthEvents(
  \luastring{\@t@monthName},
  \@t@filterPred,
  \@t@formatFunc,
  \luastringO{\@t@formatCmd},
  \luastring{\@t@eventsCsv},
  \luastring{\@t@markDefaultsCsv},
  \@t@minEvents
)}}

\def\@t@yearNum{}

% #1 = option keys
\newcommand*\parseYearEvents[1][]{%
\pgfkeys{/parseYearEvents, defaults, #1,
  year/.get=\@t@year,
  filter pred/.get=\@t@filterPred,
  format func/.get=\@t@formatFunc,
  format cmd/.get=\@t@formatCmd,
  events csv/.get=\@t@eventsCsv,
  mark defaults csv/.get=\@t@markDefaultsCsv,
  min events/.get=\@t@minEvents,
}%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
yearEvents(
  tonumber(\@t@year),
  \@t@filterPred,
  \@t@formatFunc,
  \luastringO{\@t@formatCmd},
  \luastring{\@t@eventsCsv},
  \luastring{\@t@markDefaultsCsv},
  \@t@minEvents
)}}

\newlength\dayTextXshift
\newlength\dayTextYshift
\setlength{\dayTextXshift}{0pt}
\setlength{\dayTextYshift}{0pt}

\newlength\markNumberAbove
\newlength\markNumberRight
\setlength{\markNumberAbove}{-10pt}
\setlength{\markNumberRight}{-3pt}

\newlength\markDayTextAbove
\newlength\markDayTextRight
\setlength{\markDayTextAbove}{-10pt}
\setlength{\markDayTextRight}{-3pt}

\newcommand\parseMonthMarksDayText{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksDayText(\luastring{\theMonthName}, nil, \luastring{\@wall@eventsCsv})
tex.sprint(';')
}}

\newcommand\parseMonthMarksDayTextMonth[1]{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksDayText(\luastring{#1}, nil, \luastring{\@wall@eventsCsv})
tex.sprint(';')
}}

\newcommand*\parseMonthMarksDayTextUsing[1]{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksDayText(\luastring{\theMonthName}, nil, \luastring{#1})
}}

\newcommand\parseMonthMarksDayTextMonthUsing[2]{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksDayText(\luastring{#1}, nil, \luastring{#2})
}}

\newcommand*\parseMonthMarksNote{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksNote(\luastring{\theMonthName}, nil, \luastring{\@wall@eventsCsv}, \luastring{\@wall@markDefaultsCsv})
}}

\newcommand*\parseMonthMarksNoteUsing[1]{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksNote(\luastring{\theMonthName}, nil, \luastring{#1}, \luastring{\@wall@markDefaultsCsv})
}}

\makepagestyle{month}
\makeoddhead{month}{}{}{}
\makeevenhead{month}{}{}{}
\makeoddfoot{month}{}{}{}
\makeevenfoot{month}{}{}{}

\pagestyle{month}

\NewCoffin\@wall@pageWrap
\NewCoffin\@wall@photo
\NewCoffin\@wall@quote
\NewCoffin\@wall@calendar
\NewCoffin\@wall@events

\newlength\@t@bleed
\newlength\@t@rightOffset
\newlength\@t@minipageWidth
\newlength\@t@calendar@height
\newlength\@t@calendar@hmargin
\newlength\@t@calendar@dayYshift
\newlength\@t@calendar@dayXshift
\newlength\@t@calendar@gridHeight
\newlength\@t@calendar@gridHeightFiveRows
\newlength\@t@calendar@gridHeightSixRows
\newlength\@t@xOffset
\newlength\@t@yOffset
\def\@t@file{}

\newcommand*\monthFmt{}%
\newcommand*\yearFmt{}%
\newcommand*\dayLetterColor{}%
\newcommand*\dayLetterFmt{}%
\newcommand*\dayTextFmt{}%
\newcommand*\quoteFmt{}%
\newcommand*\headingFmt{}%
\newcommand*\calendarFmt{}%
\newcommand*\eventsFmt{}%

\newcommand\@wall@layout@reset{%
  \renewcommand*\monthFmt{}%
  \renewcommand*\yearFmt{}%
  \renewcommand*\dayLetterColor{}%
  \renewcommand*\dayLetterFmt{}%
  \renewcommand*\dayTextFmt{}%
  \renewcommand*\quoteFmt{}%
  \renewcommand*\headingFmt{}%
  \renewcommand*\calendarFmt{}%
  \renewcommand*\eventsFmt{}%
  \def\@t@file{}%
  \setlength{\@t@calendar@height}{0pt}%
  \setlength{\@t@calendar@hmargin}{0pt}%
  \setlength{\@t@calendar@dayYshift}{0pt}%
  \setlength{\@t@calendar@dayXshift}{0pt}%
  \setlength{\@t@bleed}{0pt}%
  \setlength{\@t@rightOffset}{0pt}%
  \setlength{\@t@minipageWidth}{0pt}%
  \setlength{\@t@xOffset}{0pt}%
  \setlength{\@t@yOffset}{0pt}%
  \setlength{\@t@calendar@gridHeight}{0pt}%
  \setlength{\@t@calendar@gridHeightFiveRows}{0pt}%
  \setlength{\@t@calendar@gridHeightSixRows}{0pt}%
}

\newcommand\fullPageFmt{%
  \renewcommand*\monthFmt{\LARGE}%
  \renewcommand*\yearFmt{\LARGE}%
  \renewcommand*\dayLetterColor{}%
  \renewcommand*\dayLetterFmt{\tiny}%
  \renewcommand*\dayTextFmt{\small}%
  \renewcommand*\quoteFmt{}%
  \renewcommand*\headingFmt{\centering}%
  \renewcommand*\calendarFmt{\centering}%
  \renewcommand*\eventsFmt{\setlength{\parindent}{0pt}\raggedleft\footnotesize}%
}

\newcommand\@wall@fullPageLayout[2][]{%
\makeatletter
\renewcommand*\theMonthName{#2}
\@wall@layout@reset
\fullPageFmt

\colorlet{weekday}{black}
\colorlet{weekend}{black!70}

\pgfkeys{/Photo/#2/bleed/.get=\@val}
\setlength{\@t@bleed}{\@val}

\def\@t@monthnum{\monthToNum{#2}}

% 40mm = 1.5748 inch
% 43mm = 1.6929 inch
\setlength{\@t@calendar@height}{40mm + \@t@bleed}

% See if there was a height given in the options
\pgfkeys{/Calendar/#2/minimum height/.get=\@val}
\ifx\@val\empty \relax
\else
  \setlength{\@t@calendar@height}{\@val + \@t@bleed}
\fi

\setlength{\@t@calendar@hmargin}{20pt}

% NOTE: the -4pt and -2pt offset is somehow necessary for the sides to align
% with the edges
\setlength{\@t@rightOffset}{\@t@bleed +\@t@calendar@hmargin -4pt}
\setlength{\@t@minipageWidth}{\calPaperWidth -2\@t@calendar@hmargin -2pt}

\SetHorizontalCoffin\@wall@pageWrap{%
  \color{white}%
  \rule{\textwidth}{0pt}%
  \rule{0pt}{\textheight}%
}

\pgfkeys{/Photo/#2/file/.get=\@t@file}

\SetHorizontalCoffin\@wall@photo{%
  \placeholder[fill=photo-frame]{hasvarnish}{%
    \@wall@photo@putPhoto{\@t@file}%
  }%
}

\SetHorizontalCoffin\@wall@quote{%
  \placeholder[fill=quote-frame]{}{%
    \begin{minipage}{\linewidth}%
      \quoteFmt
      \pgfkeys{/Quote/#2/text/.get=\@val}%
      \@val%
    \end{minipage}%
  }%
}

\SetHorizontalCoffin\@wall@calendar{%
\ifvarnishmask\relax
\else
\begin{tikzpicture}

\node (bg) [
  fill = calendarbg,
  opacity = 0.5,
  minimum width = {\calPaperWidth + 2\@t@bleed},
  anchor=north west,
  /Calendar/#2/bg,
  % override the style, in case bleed was set above
  minimum height = {\@t@calendar@height},
] at (0,0) {};

\node (heading) [
  below right=10pt and {\@t@rightOffset} of bg.north west,
  anchor=north west,
] {%
\placeholder[fill=heading-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\headingFmt
{\monthFmt\@tr@monthNumName{\@t@monthnum}}
\hfill
\strcmpblank{\CalendarAltYear}{%
   {\yearFmt\CalendarYear}%
}{%
  {\yearFmt\CalendarYear/\CalendarAltYear}%
}%
\end{minipage}%
}%
};

\node (calendar) [
  below right=35pt and {\@t@rightOffset} of bg.north west,
  anchor=north west,
] {%
\placeholder[fill=calendar-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\calendarFmt
\tikz{\tikzMonthCalendar@fullpage{\@t@monthnum};}%
\end{minipage}%
}%
};

\node (events) [
  below=0pt of calendar.south west,
  anchor=north west,
] {%
\placeholder[fill=events-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\eventsFmt
\pgfkeys{/Events/#2/text/.get=\@val}%
\@val%
\end{minipage}%
}%
};

\end{tikzpicture}%
\fi
}% \SetHorizontalCoffin

\@wall@photo@setYOffset

\pgfkeys{/Photo/#2/xOffset/.get=\@val}
\addtolength{\@t@xOffset}{\@val}
\pgfkeys{/Photo/#2/yOffset/.get=\@val}
\addtolength{\@t@yOffset}{\@val}

% NOTE: a small whitespace is visible on the left edge of the page when bleed is 0pt, a space must be getting in somewhere.
\JoinCoffins*\@wall@pageWrap[l,t]\@wall@photo[l,t](-\spinemargin -\@t@bleed + \@t@xOffset, \uppermargin + \@t@bleed + \@t@yOffset)

\pgfkeys{/Quote/#2/xOffset/.get=\@val}
\setlength{\@t@xOffset}{\@val}
\pgfkeys{/Quote/#2/yOffset/.get=\@val}
\setlength{\@t@yOffset}{\@val}

\JoinCoffins*\@wall@pageWrap[l,t]\@wall@quote[l,t](\@t@xOffset, \@t@yOffset)

\JoinCoffins*\@wall@pageWrap[l,b]\@wall@calendar[l,b](-\spinemargin -\@t@bleed, \textheight +\uppermargin -\paperheight -\@t@bleed)

\makeatother

\clearpage
\TypesetCoffin\@wall@pageWrap%
}% \@wall@fullPageLayout

\newcommand*{\tikzMonthCalendar@fullpage}[1]{%
\pgfkeys{/Events/\monthName{#1}/marks/.get=\@eventmarks}%
\calendar (cal#1) [alnitak, dates=\CalendarYear-#1-01 to \CalendarYear-#1-last] \@eventmarks;%
}

\newcommand\smallLandscapeFmt{%
  \renewcommand*\monthFmt{\LARGE}%
  \renewcommand*\yearFmt{\LARGE}%
  \renewcommand*\dayLetterColor{}%
  \renewcommand*\dayLetterFmt{\tiny}%
  \renewcommand*\dayTextFmt{\small}%
  \renewcommand*\quoteFmt{\centering}%
  \renewcommand*\headingFmt{\centering}%
  \renewcommand*\calendarFmt{\centering}%
  \renewcommand*\eventsFmt{\setlength{\parindent}{0pt}\raggedright\footnotesize}%
}

\newcommand\@wall@smallLandscapeLayout[2][]{%
\makeatletter
\renewcommand*\theMonthName{#2}
\@wall@layout@reset
\smallLandscapeFmt

\colorlet{weekday}{black}
\colorlet{weekend}{black!70}

\pgfkeys{/Photo/#2/bleed/.get=\@val}
\setlength{\@t@bleed}{\@val}

\def\@t@monthnum{\monthToNum{#2}}

\setlength{\@t@calendar@height}{85mm + \@t@bleed}

% See if there was a height given in the options
\pgfkeys{/Calendar/#2/minimum height/.get=\@val}
\ifx\@val\empty \relax
\else
  \setlength{\@t@calendar@height}{\@val + \@t@bleed}
\fi

\setlength{\@t@calendar@hmargin}{20pt}

% 5mm: day headings
% 20mm: events
% 6.5mm: vertical spacing
\setlength{\@tmp@a}{20mm + 5mm + 6.5mm}
\setlength{\@tmp@b}{\@t@calendar@height -\@tmp@a}
\setlength{\@t@calendar@dayYshift}{0.1666\@tmp@b}% 1/6 = 0.1666

\setlength{\@t@calendar@gridHeightSixRows}{\@tmp@b}
\setlength{\@t@calendar@gridHeightFiveRows}{\@tmp@b -0.1666\@tmp@b}

% NOTE: the -4pt and -2pt offset is somehow necessary for the sides to align
% with the edges
\setlength{\@t@rightOffset}{\@t@bleed +\@t@calendar@hmargin -4pt}
\setlength{\@t@minipageWidth}{\calPaperWidth -2\@t@calendar@hmargin -2pt}

\setlength{\@t@calendar@dayXshift}{0.1428\@t@minipageWidth}% 1/7 = 0.1428

\SetHorizontalCoffin\@wall@pageWrap{%
  \color{white}%
  \rule{\textwidth}{0pt}%
  \rule{0pt}{\textheight}%
}

\pgfkeys{/Photo/#2/file/.get=\@t@file}

\SetHorizontalCoffin\@wall@photo{%
  \placeholder[fill=photo-frame]{hasvarnish}{%
    \@wall@photo@putPhoto{\@t@file}%
  }%
}

\SetHorizontalCoffin\@wall@quote{%
  \placeholder[fill=quote-frame]{}{%
    \begin{minipage}{\linewidth}%
      \quoteFmt
      \pgfkeys{/Quote/#2/text/.get=\@val}%
      \@val%
    \end{minipage}%
  }%
}

\SetHorizontalCoffin\@wall@calendar{%
\ifvarnishmask\relax
\else
\begin{tikzpicture}

\node (bg) [
  fill = calendarbg,
  opacity = 1,
  minimum width = {\calPaperWidth + 2\@t@bleed},
  anchor=north west,
  /Calendar/#2/bg,
  % override the style, in case bleed was set above
  minimum height = {\@t@calendar@height},
] at (0,0) {};

\node (heading) [
  below right=10pt and {\@t@rightOffset} of bg.north west,
  anchor=north west,
] {%
\placeholder[fill=heading-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\headingFmt
{\monthFmt\@tr@monthNumName{\@t@monthnum}}
\hfill
\strcmpblank{\CalendarAltYear}{%
   {\yearFmt\CalendarYear}%
}{%
  {\yearFmt\CalendarYear/\CalendarAltYear}%
}%
\end{minipage}%
}%
};

\node (calendar) [
  below right=35pt and {\@t@rightOffset} of bg.north west,
  anchor=north west,
] {%
\placeholder[fill=calendar-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\calendarFmt
\hspace*{-5pt}% FIXME
\tikz{\tikzMonthCalendar@smallLandscape{\@t@monthnum};}%
\end{minipage}%
}%
};

\node (events) [
  above right=10mm and {\@t@rightOffset} of bg.south west,
  anchor=south west,
] {%
\placeholder[fill=events-frame]{}{%
\begin{minipage}{\@t@minipageWidth}%
\eventsFmt
\pgfkeys{/Events/#2/text/.get=\@val}%
\@val%
\end{minipage}%
}%
};

\end{tikzpicture}%
\fi
}% \SetHorizontalCoffin

% The quote has to be centered b/w the photo and the calendar with manual tweaking.
% The height of the quote is not known, the height of the calendar plus its heading is not known.

\pgfkeys{/Quote/#2/yOffset/.get=\@val}
\setlength{\@t@yOffset}{\@val}

\JoinCoffins*\@wall@photo[hc,b]\@wall@quote[hc,t](0pt, \@t@yOffset)

\pgfkeys{/Photo/#2/yOffset/.get=\@val}
\setlength{\@t@yOffset}{\@val}

% NOTE: Taking the bottom edge of the photo as fixed.
% yOffset must be set to pull the photo down into position

\JoinCoffins*\@wall@pageWrap[hc,t]\@wall@photo[hc,b](0pt, \uppermargin + \@t@yOffset)

% Calendar is aligned to the bottom of the page.

\JoinCoffins*\@wall@pageWrap[hc,b]\@wall@calendar[hc,b](0pt, \textheight +\uppermargin -\paperheight -\@t@bleed)

\makeatother

\clearpage
\TypesetCoffin\@wall@pageWrap%
}% \@wall@smallLandscapeLayout

\newcommand*{\tikzMonthCalendar@smallLandscape}[1]{%
\pgfkeys{/Events/\monthName{#1}/marks/.get=\@eventmarks}%
\calendar (cal#1) [betelgeuse, dates=\CalendarYear-#1-01 to \CalendarYear-#1-last] \@eventmarks;%
}

\tikzstyle{day letter headings}=[%
  day heading/.style={black!90},
  execute before day scope={%
    \ifdate{day of month=1}{%
      \pgfmathsetlength\pgf@xa{\tikz@lib@cal@xshift}%
      \pgfmathsetlength\pgf@ya{\tikz@lib@cal@yshift}%
      \foreach \d in {0,1,2,3,4,5,6} {%
        \pgf@xa=\d\pgf@xa%
        \pgftransformxshift{\pgf@xa}%
        \pgftransformyshift{\pgf@ya}%
        \node (d\d) [anchor=south, day heading] {\dayLetterFmt\@tr@dayLetter{\d}};%
      };%
    }{}%
  },%
]

\newcount\gridRows
\newcount\gridLines
\newcount\n

\newif\ifGridNoSurround
\GridNoSurroundfalse

\tikzstyle{no grid surround}=[execute before day scope={\GridNoSurroundtrue}]
\tikzstyle{grid surround}=[execute before day scope={\GridNoSurroundfalse}]

\tikzstyle{days grid}=[%
  execute before day scope={%
    \ifdate{day of month=1}{%
      %
      % Determine if the grid is five or six rows
      %
      % 31 day months
      \ifdate{between=01-01 and 01-31, between=03-01 and 03-31, between=05-01 and 05-31, between=07-01 and 07-31, between=08-01 and 08-31, between=10-01 and 10-31, between=12-01 and 12-31}{%
        \ifdate{Saturday,Sunday}{%
          \gridRows=6%
          \setlength\@t@calendar@gridHeight{\@t@calendar@gridHeightSixRows}%
        }{%
          \gridRows=5%
          \setlength\@t@calendar@gridHeight{\@t@calendar@gridHeightFiveRows}%
        }
      }{
      % 30 day months and February
        \ifdate{between=02-01 and 02-last}{%
          \gridRows=5%
          \setlength\@t@calendar@gridHeight{\@t@calendar@gridHeightFiveRows}%
        }{%
          \ifdate{Sunday}{%
            \gridRows=6%
            \setlength\@t@calendar@gridHeight{\@t@calendar@gridHeightSixRows}%
          }{%
            \gridRows=5%
            \setlength\@t@calendar@gridHeight{\@t@calendar@gridHeightFiveRows}%
          }
        }
      }
      %
      % Horizontal lines
      %
      \gridLines=\gridRows
      \ifGridNoSurround\relax
      \else
        \advance\gridLines by 1
        \n=0
        \draw [
          gridcolor,
          line width=0.3pt,
          xshift=-0.5\@t@calendar@dayXshift,
          yshift=0.5\@t@calendar@dayYshift,
        ] (0,{-\n\@t@calendar@dayYshift}) -- (7\@t@calendar@dayXshift,{-\n\@t@calendar@dayYshift});
      \fi
      \foreach \n in {1,2,3,4,5,6} {
        \ifnum\n<\gridLines
          \draw [
            gridcolor,
            line width=0.3pt,
            xshift=-0.5\@t@calendar@dayXshift,
            yshift=0.5\@t@calendar@dayYshift,
          ] (0,{-\n\@t@calendar@dayYshift}) -- (7\@t@calendar@dayXshift,{-\n\@t@calendar@dayYshift});
        \fi
      }
      %
      % Vertical lines
      %
      \gridLines=7
      \ifGridNoSurround\relax
      \else
        \advance\gridLines by 1
        \n=0
        \draw [
          gridcolor,
          line width=0.3pt,
          xshift=-0.5\@t@calendar@dayXshift,
          yshift=0.5\@t@calendar@dayYshift,
        ] ({\n\@t@calendar@dayXshift},0) -- ({\n\@t@calendar@dayXshift},{-\gridRows\@t@calendar@dayYshift});
      \fi
      \foreach \n in {1,2,3,4,5,6,7} {
        \ifnum\n<\gridLines
          \draw [
            gridcolor,
            line width=0.3pt,
            xshift=-0.5\@t@calendar@dayXshift,
            yshift=0.5\@t@calendar@dayYshift,
          ] ({\n\@t@calendar@dayXshift},0) -- ({\n\@t@calendar@dayXshift},{-\gridRows\@t@calendar@dayYshift});
        \fi
      }
      %
      % If we are not drawing the surrounding lines, it looks better to hide
      % some of the top and bottom edges
      %
      \ifGridNoSurround
        \draw [
          color=white,
          line width=6pt,
          xshift=-0.5\@t@calendar@dayXshift,
          yshift={0.5\@t@calendar@dayYshift -1pt},
        ] (0,0) -- (7\@t@calendar@dayXshift,0);
        \draw [
          color=white,
          line width=6pt,
          xshift=-0.5\@t@calendar@dayXshift,
          yshift={0.5\@t@calendar@dayYshift +1pt},
        ] (0,-\gridRows\@t@calendar@dayYshift) -- (7\@t@calendar@dayXshift,-\gridRows\@t@calendar@dayYshift);
      \fi
    }{}%
  }
]

\tikzstyle{headings background rule}=[
  background rule/.style={black!90, line width=0.3pt, yshift={0.3\@t@calendar@dayYshift -3pt}},
  execute before day scope={%
    \ifdate{day of month=1}{%
      \draw [
        xshift=-0.5\@t@calendar@dayXshift,
        yshift=0.5\@t@calendar@dayYshift,
        background rule,
      ] (0,0) -- (7\@t@calendar@dayXshift,0);
    }{}%
  }
]

\tikzstyle{headings background bar}=[
  headings background rule,
  background rule/.style={black!20, line width=10pt, yshift={0.3\@t@calendar@dayYshift +3.5pt}},
]

\tikzstyle{betelgeuse}=[
  no grid surround,
  days grid,
  week list,
  day xshift=\@t@calendar@dayXshift,
  day yshift=\@t@calendar@dayYshift,
  headings background bar,
  day letter headings,
  day heading/.style={black!90, yshift={-0.3\@t@calendar@dayYshift}},
  every day/.append style={anchor=base, inner xsep=0pt, yshift={-0.25\baselineskip}},
  day text={\dayTextFmt\%d-},
]

\tikzstyle{alnitak}=[
  day list right,
  day xshift={0pt},
  every month/.append style={anchor=base, inner xsep=0pt, yshift=4mm, xshift=-\widthof{\space}},
  day text={\dayTextFmt\%d-},
  every day/.append style={anchor=base, inner xsep=0pt},
  execute before day scope={
    %
    % === Moving the day number ===
    %
    % A small offset seems to improve the result, the last day gets closer to the end of the linewidth
    \pgftransformxshift{0.01em}
    \pgfcalendarjuliantodate{\pgfcalendarendjulian}{\currentyear}{\currentmonth}{\lastday}
    % Width of month day digits from 1 - 28
    \setlength{\@tmp@a}{\widthof{12345678910111213141516171819202122232425262728}}
    \setlength{\@tmp@b}{\widthof{30}}
    \pgfmathparse{(\linewidth - \@tmp@a - \@tmp@b * (\lastday-28)) / \lastday}
    \pgftransformxshift{\pgfmathresult}
    \let\%=\pgfcalendarshorthand
    \setlength{\@tmp@a}{\widthof{\%d-}}
    \pgftransformxshift{\@tmp@a}
    %
    % === Weekday letter above the day ===
    %
    \ifdate{weekend}{\def\dayLetterColor{\color{weekend}}}{\def\dayLetterColor{\color{weekday}}}%
    \node[anchor=south,yshift=5mm,inner sep=0pt]{%
      \dayLetterColor\dayLetterFmt\@tr@dayLetter{\pgfcalendarcurrentweekday}%
    };%
  },
]

\newcommand\plannerMonthFmt{\fontsize{11}{11}\selectfont\color{darkgold}}
\newcommand\plannerDayFmt{\fontsize{8}{8}\selectfont\color{plannerdatenum}}

\tikzstyle{year planner}=[
  week list,
  month text={\plannerMonthFmt\@tr@monthNumName{\pgfcalendarcurrentmonth}},
  day text={\plannerDayFmt\%d-},
  every month/.append style={%
    anchor=south,
    inner xsep=0pt,
    yshift=5mm,
    xshift=2.5mm,
  },
  day letter headings,
  day heading/.style={gray, xshift=0pt, scale=0.85},
  month label above centered,
  every day/.style={anchor=mid},
]

\newcommand\plannerMarksDayTextCSV{\@wall@eventsCsv}
\newcommand\plannerMarksNoteCSV{\@wall@eventsCsv}
\newcommand\plannerMarkDefaultsCsv{}

\newcommand\@wall@plm[1]{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
monthMarksDayText(\luastring{#1}, nil, \luastring{\plannerMarksDayTextCSV})
tex.sprint(';')
}}

\newcommand\@wall@plNotes{%
\luadirect{
require("./scripts/wallcalendar-helpers.lua")
yearMarksNote(tonumber(\CalendarYear), nil, \luastring{\plannerMarksNoteCSV}, \luastring{\plannerMarkDefaultsCsv})
}}

\newcommand\plannerEvents{%
\parseYearEvents[filter pred = hasNote]%
}

\newcommand\YearPlanner{%
\begin{tikzpicture}[every calendar/.style={year planner}]%
  \matrix[column sep=1.5em, row sep=5mm] {
    \calendar(cal01)[dates=\CalendarYear-01-01 to \CalendarYear-01-last] \@wall@plm{January};   \pgfmatrixnextcell
    \calendar(cal02)[dates=\CalendarYear-02-01 to \CalendarYear-02-last] \@wall@plm{February};  \pgfmatrixnextcell
    \calendar(cal03)[dates=\CalendarYear-03-01 to \CalendarYear-03-last] \@wall@plm{March};     \\
    \calendar(cal04)[dates=\CalendarYear-04-01 to \CalendarYear-04-last] \@wall@plm{April};     \pgfmatrixnextcell
    \calendar(cal05)[dates=\CalendarYear-05-01 to \CalendarYear-05-last] \@wall@plm{May};       \pgfmatrixnextcell
    \calendar(cal06)[dates=\CalendarYear-06-01 to \CalendarYear-06-last] \@wall@plm{June};      \\
    \calendar(cal07)[dates=\CalendarYear-07-01 to \CalendarYear-07-last] \@wall@plm{July};      \pgfmatrixnextcell
    \calendar(cal08)[dates=\CalendarYear-08-01 to \CalendarYear-08-last] \@wall@plm{August};    \pgfmatrixnextcell
    \calendar(cal09)[dates=\CalendarYear-09-01 to \CalendarYear-09-last] \@wall@plm{September}; \\
    \calendar(cal10)[dates=\CalendarYear-10-01 to \CalendarYear-10-last] \@wall@plm{October};   \pgfmatrixnextcell
    \calendar(cal11)[dates=\CalendarYear-11-01 to \CalendarYear-11-last] \@wall@plm{November};  \pgfmatrixnextcell
    \calendar(cal12)[dates=\CalendarYear-12-01 to \CalendarYear-12-last] \@wall@plm{December};  \\
  };
  \@wall@plNotes
\end{tikzpicture}%
}

% Load internal translations
\InputIfFileExists{i18n/\@wall@calendarLanguage.tex}{}%
{\ClassError{wallcalendar}{File Not Found: i18n/\@wall@calendarLanguage.tex}{}}

% Load user translations if the option was set and translationsAutoload is true

\newcommand\LoadTranslations{%
\InputIfFileExists{\@wall@translationsInputFile}{}%
{\ClassWarning{wallcalendar}{File Not Found: \@wall@translationsInputFile}{}}}

\notblank{\@wall@translationsInputFile}{%
\iftranslationsAutoload \LoadTranslations \fi}

\newcommand*\@tr@monthNumName[1]{%
% \ifcase might be just fine here
\luadirect{
  local monthName = {
    '\xJanuary', '\xFebruary', '\xMarch', '\xApril', '\xMay', '\xJune', '\xJuly',
    '\xAugust', '\xSeptember', '\xOctober', '\xNovember', '\xDecember',
  }
  local key = tonumber('#1')
  tex.sprint(monthName[key])
}}

\newcommand*\@tr@dayLetter[1]{%
% \ifcase might be just fine here
\luadirect{
  local dayLetter = {
    '\xMondayDayLetter', '\xTuesdayDayLetter', '\xWednesdayDayLetter',
    '\xThursdayDayLetter', '\xFridayDayLetter', '\xSaturdayDayLetter', '\xSundayDayLetter',
  }
  local key = tonumber('#1')+1
  tex.sprint(dayLetter[key])
}}

\newcommand*{\monthToNum}[1]{%
\luadirect{
  local monthToNum = {
    january   = '01',
    february  = '02',
    march     = '03',
    april     = '04',
    may       = '05',
    june      = '06',
    july      = '07',
    august    = '08',
    september = '09',
    october   = '10',
    november  = '11',
    december  = '12',
  }
  local key = string.lower('#1')
  tex.sprint(monthToNum[key])
}}

\newcommand*\monthName[1]{%
% \ifcase might be just fine here
\luadirect{
  local monthName = {
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  }
  local key = tonumber('#1')
  tex.sprint(monthName[key])
}}

% End of wallcalendar.cls