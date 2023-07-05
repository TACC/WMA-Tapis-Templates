## MATLAB at LoneStar6

The `profile.json` contains the definition of the scheduler profile.

The `app.json` contains the basic definition of the application. Use `client.apps.createAppVersion(**app_def)` to create the application. 

Although this application could not be tested in LoneStar6 because of the lack of interactive session, this has been tested in Frontera. Please update the `app.json` file accordingly with the updated code of DCV/VNC server at LS6.

Here's a sample output of the test in frontera system:

<img width="1664" alt="Screenshot 2023-07-05 at 11 06 19 AM" src="https://github.com/TACC/WMA-Tapis-Templates/assets/43958517/716cc659-02e4-498b-8698-46d1bc84780a">
