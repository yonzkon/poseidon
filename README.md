# Poseidon
Poseidon server only for openkore-cro

# What is Poseidon? (Must understand it first!)
- http://openkore.com/index.php/Poseidon

# Steps to run Poseidon & openkore(cro branch)

## STEP 1 - Run Poseidon in VM or VPS or DOCKER or WSL
- perl src/poseidon.pl --char-server=\<YOUR VM IP:6900\> --map-server=\<YOUR VM IP:6900\>

## STEP 2 - Make poseidon.xml
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon.xml.png)

## STEP 3 - Start Ragexe to login Poseidon
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/ragexe-shortcut.png)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/login.png)

## STEP 4 - Check Poseidon's output
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon2.png)

## STEP 5 - Capture the login password which is encrypted in rijndael (32 bytes)
![image](https://github.com/yon2kong/Poseidon/blob/master/doc/password.png)

## STEP 6 - Modify control/config.txt
- password \<CAPTURED LOGIN PASSWORD\>
- poseidonServer \<YOUR VM IP\>
- gameGuard 1

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/config.png)

## SETP 7 - Checkout cro branch AND start OpenKore
- git clone https://github.com/yon2kong/openkore.git && cd openkore
- git checkout cro
- start openkore and check Poseidon's output.

![image](https://github.com/yon2kong/Poseidon/blob/master/doc/poseidon3.png)
