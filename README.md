# Poseidon
Poseidon server only for openkore-cro

# Steps to run openkore-cro and Poseidon

## STEP 1 - Run Poseidon in VM or VPS or DOCKER or WSL
- perl src/poseidon.pl --char-server=\<YOUR VM IP:6900\> --map-server=\<YOUR VM IP:6900\>

## STEP 2 - Make poseidon.xml AND start Ragnarok Client (Ragexe)
- http://openkore.com/index.php/Poseidon

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon.xml.png)

- Check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon2.png)

## STEP 3 - Capture the login password which is encrypted in rijndael (32 bytes)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/password.png)

## STEP 4 - Modify control/config.txt
- password \<CAPTURED LOGIN PASSWORD\>
- poseidonServer \<YOUR VM IP\>
- gameGuard 1

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/config.png)

## SETP 5 - Checkout cro branch AND start OpenKore
- git clone https://github.com/yon2kong/openkore.git && cd openkore
- git checkout cro
- start openkore and check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon3.png)
