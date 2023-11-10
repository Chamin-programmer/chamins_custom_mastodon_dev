import logo from 'mastodon/../images/logo.png';

export const WordmarkLogo: React.FC = () => (
  <img src="./images/logo.png" height="32px" />
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);
