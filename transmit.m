% Transmitter parameter structure
prmQPSKTransmitter = sdruqpsktransmitter_init(platform)
prmQPSKTransmitter.Platform = platform;
prmQPSKTransmitter.Address = address;
compileIt  = false; % true if code is to be compiled for accelerated execution
useCodegen = false; % true to run the latest generated mex file