# Tamplate Project Hyperledger Fabric

## Configurasi Peer
Perlu diperhatikan untuk menggunakan project ini perlu melakukan configurasi peer kedalam user logs pada ~/.bashrc.

Dengan cara masukan path dari bin pada tamplate kedalam ~/.bashrc. Folder bin disini berfungsi sebagai berbagai macam configurasi untuk peer. dan configurasi peer yang digunakan adalah versi **v2.5.4**. 

File bin ini diambil dari folder fabric-samples hyperledger fabric. jika terjadi update pada hyperledger fabric, gunakan lah yang lebih baru.

### Tahapan
```bash
$ nano ~/.bashrc

```
masukkan path bin pada bashrc

```bash
export PATH=$PATH:/{your_path_folder}/Tutorial_HyperledgerFabric_BahasaIndonesia/bin
```
kemudian save denga `ctrl+s` dan exit `ctrl+x`

Kemudian reboot system.

### Check Peers Config
Untuk mengecheck peer telah terpasang dapat menjalankan code
```bash
peer
```
untuk mengecheck version
```bash
peer version
```
