# Poseidon
Poseidon server only for openkore-cro

# steps to use openkore-cro and Poseidon

## STEP 1 - Capture the login password which is encrypted in rijndael (32 bytes)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/password.png)

## STEP 2 - Config your control/config.txt
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/config.png)

## STEP 3 - Run Poseidon in your VM or VPS
- ./poseidon.pl --char-server=\<YOUR VM IP:6900\> --map-server=\<YOUR VM IP:6900\>

## STEP 4 - Make poseidon.xml AND start Ragnarok Client (Ragexe)
- http://openkore.com/index.php/Poseidon

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon.xml.png)

- Check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon2.png)

## SETP 5 - Checkout cro branch AND start OpenKore
- git clone https://github.com/yon2kong/openkore.git && cd openkore
- git checkout cro
- start openkore and check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon3.png)
