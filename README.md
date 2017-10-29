# Poseidon
Poseidon server only for openkore-cro

# What is Poseidon? (Must understand it first!)
- http://openkore.com/index.php/Poseidon

# PHASE 1
- run poseidon
- run cro-client slaves
- one slave can only handle one openkore
- If you want to run 3 openkore, run 3 cro-client slaves first.

## STEP 1.1 - Run Poseidon in VM or VPS or DOCKER or WSL
- perl src/poseidon.pl --char-server=\<YOUR VM IP:6900\> --map-server=\<YOUR VM IP:6900\>

## STEP 1.2 - Make poseidon.xml
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon.xml.png)

## STEP 1.3 - Run cro-client slaves to login Poseidon
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/ragexe-shortcut.png)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/login.png)

## STEP 1.4 - Check Poseidon's output
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon2.png)

# PHASE 2
- run openkore
- openkore can't run with cro-client in same OS

## STEP 2.1 - Capture the login password which is encrypted in rijndael (32 bytes)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/password.png)

## STEP 2.2 - Modify control/config.txt
- password \<CAPTURED LOGIN PASSWORD\>
- poseidonServer \<YOUR VM IP\>
- gameGuard 1

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/config.png)

## SETP 2.3 - Checkout cro branch AND start OpenKore
- git clone https://github.com/yon2kong/openkore.git && cd openkore
- git checkout cro
- start openkore and check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon3.png)
