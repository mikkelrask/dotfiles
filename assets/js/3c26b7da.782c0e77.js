"use strict";(self.webpackChunkdotfile_docs=self.webpackChunkdotfile_docs||[]).push([[7173],{4203:(e,l,i)=>{i.r(l),i.d(l,{assets:()=>r,contentTitle:()=>a,default:()=>h,frontMatter:()=>n,metadata:()=>d,toc:()=>c});var s=i(4848),t=i(8453);const n={sidebar_position:2,tags:["bash","shell","custom utilities","install.sh"]},a="Custom Utilities",d={id:"packages/custom-utils",title:"Custom Utilities",description:"Install scripts",source:"@site/docs/packages/custom-utils.md",sourceDirName:"packages",slug:"/packages/custom-utils",permalink:"/docs/packages/custom-utils",draft:!1,unlisted:!1,editUrl:"https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/docs/packages/custom-utils.md",tags:[{label:"bash",permalink:"/docs/tags/bash"},{label:"shell",permalink:"/docs/tags/shell"},{label:"custom utilities",permalink:"/docs/tags/custom-utilities"},{label:"install.sh",permalink:"/docs/tags/install-sh"}],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2,tags:["bash","shell","custom utilities","install.sh"]},sidebar:"tutorialSidebar",previous:{title:"Included packages",permalink:"/docs/category/included-packages"},next:{title:"All the packages!",permalink:"/docs/packages/all-packages"}},r={},c=[{value:"Install scripts",id:"install-scripts",level:2},{value:"Packages",id:"packages",level:3},{value:"cava",id:"cava",level:4},{value:"i3wm",id:"i3wm",level:4},{value:"Dunst",id:"dunst",level:4},{value:"Hyprland",id:"hyprland",level:4},{value:"Kitty",id:"kitty",level:4},{value:"Newsboat",id:"newsboat",level:4},{value:"Nvim",id:"nvim",level:4},{value:"Tmux",id:"tmux",level:4},{value:"Zsh",id:"zsh",level:4},{value:"Packages included in the custom installers that don&#39;t require dotfiles",id:"packages-included-in-the-custom-installers-that-dont-require-dotfiles",level:3},{value:"Bun",id:"bun",level:4},{value:"Bitwarden*",id:"bitwarden",level:4},{value:"Parsec*",id:"parsec",level:4},{value:"Dotfiles",id:"dotfiles",level:3},{value:"General <em>Quality-of-life</em> utilities",id:"general-quality-of-life-utilities",level:2},{value:"bat",id:"bat",level:4},{value:"dmenu_power",id:"dmenu_power",level:4},{value:"dmenuunicode",id:"dmenuunicode",level:4},{value:"linkhandler",id:"linkhandler",level:4},{value:"moar",id:"moar",level:4},{value:"tmex",id:"tmex",level:4},{value:"themesetter",id:"themesetter",level:4},{value:"wallsetter",id:"wallsetter",level:4}];function o(e){const l={a:"a",br:"br",code:"code",em:"em",h1:"h1",h2:"h2",h3:"h3",h4:"h4",p:"p",pre:"pre",...(0,t.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(l.h1,{id:"custom-utilities",children:"Custom Utilities"}),"\n",(0,s.jsx)(l.h2,{id:"install-scripts",children:"Install scripts"}),"\n",(0,s.jsx)(l.p,{children:"To install everything at once, like when deploying a new machine you simply clone the dotfiles repository, and execute the correct installer through any old terminal."}),"\n",(0,s.jsx)(l.pre,{children:(0,s.jsx)(l.code,{className:"language-shell",metastring:'title="Install packages and their dotfiles"',children:"git clone git@github.com:mikkelrask/dotfiles\ncd dotfiles\nchmod +x install*\n\n# Install everything at once\n./install.sh\n\n# Install packages only\n./install_packages.sh\n\n# Install dotfiles only*\n./install_dotfiles.sh\n"})}),"\n",(0,s.jsx)(l.h3,{id:"packages",children:"Packages"}),"\n",(0,s.jsx)(l.h4,{id:"cava",children:"cava"}),"\n",(0,s.jsx)(l.h4,{id:"i3wm",children:"i3wm"}),"\n",(0,s.jsx)(l.h4,{id:"dunst",children:"Dunst"}),"\n",(0,s.jsx)(l.h4,{id:"hyprland",children:"Hyprland"}),"\n",(0,s.jsx)(l.h4,{id:"kitty",children:"Kitty"}),"\n",(0,s.jsx)(l.h4,{id:"newsboat",children:"Newsboat"}),"\n",(0,s.jsx)(l.h4,{id:"nvim",children:"Nvim"}),"\n",(0,s.jsx)(l.h4,{id:"tmux",children:"Tmux"}),"\n",(0,s.jsx)(l.h4,{id:"zsh",children:"Zsh"}),"\n",(0,s.jsx)(l.h3,{id:"packages-included-in-the-custom-installers-that-dont-require-dotfiles",children:"Packages included in the custom installers that don't require dotfiles"}),"\n",(0,s.jsxs)(l.p,{children:["Again - since this is just as much me sharing my dotfiles with future me, i've also left in some non-dotfiles-related packages here in the installers section, as these typically aren't bundled in the default repos, or when they are, not always of the latest version. Obviously, if you're using Arch, these installers are almost redundant, and are more of a \"shortcut\" to easily install a bunch of packages, but hey, here we are.",(0,s.jsx)(l.br,{}),"\n",'All of these "extras" can easily be omitted in the installation process by appending the ',(0,s.jsx)(l.code,{children:"--light-install"}),"-flag (",(0,s.jsx)(l.code,{children:"-li"}),") when invoking either ",(0,s.jsx)(l.code,{children:"install.sh"})," or ",(0,s.jsx)(l.code,{children:"install_packages.sh"})]}),"\n",(0,s.jsx)(l.pre,{children:(0,s.jsx)(l.code,{className:"language-bash",children:"./install.sh -li # Will install all packages and dependencies mentioned above, and their dotfiles\n./install_packages.sh -li # Will install all the packages mentioned above\n"})}),"\n",(0,s.jsx)(l.h4,{id:"bun",children:"Bun"}),"\n",(0,s.jsxs)(l.p,{children:["Bun is a nice lightweight alternative to use ",(0,s.jsx)(l.code,{children:"NodeJS"}),", but also node package managers like ",(0,s.jsx)(l.code,{children:"npm"})," or ",(0,s.jsx)(l.code,{children:"yarn"}),". ",(0,s.jsx)(l.a,{href:"/docs/packages/bun/",children:"See more"})]}),"\n",(0,s.jsx)(l.h4,{id:"bitwarden",children:"Bitwarden*"}),"\n",(0,s.jsx)(l.h4,{id:"parsec",children:"Parsec*"}),"\n",(0,s.jsx)(l.h3,{id:"dotfiles",children:"Dotfiles"}),"\n",(0,s.jsxs)(l.h2,{id:"general-quality-of-life-utilities",children:["General ",(0,s.jsx)(l.em,{children:"Quality-of-life"})," utilities"]}),"\n",(0,s.jsx)(l.h4,{id:"bat",children:"bat"}),"\n",(0,s.jsx)(l.h4,{id:"dmenu_power",children:"dmenu_power"}),"\n",(0,s.jsx)(l.h4,{id:"dmenuunicode",children:"dmenuunicode"}),"\n",(0,s.jsx)(l.h4,{id:"linkhandler",children:"linkhandler"}),"\n",(0,s.jsx)(l.h4,{id:"moar",children:"moar"}),"\n",(0,s.jsx)(l.h4,{id:"tmex",children:"tmex"}),"\n",(0,s.jsx)(l.h4,{id:"themesetter",children:"themesetter"}),"\n",(0,s.jsx)(l.h4,{id:"wallsetter",children:"wallsetter"})]})}function h(e={}){const{wrapper:l}={...(0,t.R)(),...e.components};return l?(0,s.jsx)(l,{...e,children:(0,s.jsx)(o,{...e})}):o(e)}},8453:(e,l,i)=>{i.d(l,{R:()=>a,x:()=>d});var s=i(6540);const t={},n=s.createContext(t);function a(e){const l=s.useContext(n);return s.useMemo((function(){return"function"==typeof e?e(l):{...l,...e}}),[l,e])}function d(e){let l;return l=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:a(e.components),s.createElement(n.Provider,{value:l},e.children)}}}]);