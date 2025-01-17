# sensors-threshold
A temperature sensor threshold for Linux and warn you if anormal temp is detected via Discord Webhook

Monitor your server or computer CPU temperature and it warn you if the temperature is too hot or too cold.

# Installation

## Requirements
- Need to be `root` user
- The packages `lm-sensors` and `curl` must be installed and you must have previously run the `sudo sensors-detect` as root.
- Need have a Discord Webhook Created ([tutorial](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks))

## Installation

1. Download and upload (via SFTP) `cpu-threshold.sh` to `/usr/local/bin` directory.

> You can also download and open the script in a graphical text editor (such as KWrite, VSCode, ...) and upload later to the server the saved script.

2. Add your Discord webhook URL to `WEBHOOK_URL`

> You can customize the colors by modifing this value (`"3447003"` Hex code to decimal code !) at this line `send_discord_message "3447003" "...." "...."`.
>
> You can also modify the threshold values according your needs.

## Running the script

1. Make sure you are and the script is uploaded to `/usr/local/bin` directory.
2. Run the command `chmod +x cpu-threshold.sh`.
3. Run the script `./cpu-threshold.sh`.

## Testing the notifications

You can stress the CPU to check if the webhook notifications send properly.

## Schedule the script execution at the machine startup

We need to create a systemd service to be started at the startup machine.

1. Make a service file for systemd
```
sudo nano /etc/systemd/system/sensors-threshold.service
```

2. Add the following content:
```
[Unit]
Description=A temperature sensor threshold for Linux and warn you if anormal temp is detected via Discord Webhook
After=network.target

[Service]
ExecStart=/usr/local/bin/cpu-threshold.sh
Restart=always
User=root
Environment=WEBHOOK_URL= #PUT YOUR DISCORD WEBHOOK URL HERE

[Install]
WantedBy=multi-user.target
```

3. Reload systemd and enable the service
```
sudo systemctl daemon-reload
sudo systemctl enable sensors-threshold.service
sudo systemctl start sensors-threshold.service
```

4. Check if the `sensors-threshold.service` is running
```
sudo systemctl status sensors-threshold.service
```

# Issues

You can report an [issue](https://github.com/ngrt-sh/sensors-threshold/issues)
