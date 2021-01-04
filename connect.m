connectedRadios = findsdru;
if strncmp(connectedRadios(1).Status, 'Success', 7)
  switch connectedRadios(1).Platform
    case {'B200','B210'}
      address = connectedRadios(1).SerialNum;
      platform = connectedRadios(1).Platform;
    case {'N200/N210/USRP2'}
      address = connectedRadios(1).IPAddress;
      platform = 'N200/N210/USRP2';
    case {'X300','X310'}
      address = connectedRadios(1).IPAddress;
      platform = connectedRadios(1).Platform;
  end
else
  address = '192.168.10.2';
  platform = 'N200/N210/USRP2';
end