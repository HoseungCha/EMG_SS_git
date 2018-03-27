function send_email(address, subject, message)

%SEND_EMAIL Summary of this function goes here
%   Detailed explanation goes here

try
    % internet connection check
    check_address = java.net.InetAddress.getByName('www.google.com');
    
    % Send e-mail
    % Modify these two lines to reflect
    % your account and password.
    myaddress = 'pop3812@gmail.com';
    mypassword = 'bbrain338';

    setpref('Internet','E_mail', myaddress);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username', myaddress);
    setpref('Internet','SMTP_Password', mypassword);

    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
                      'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    sendmail(address, subject, message);
    
    disp('E-mail has been delivered successfully.');
catch
    disp('Check your Internet Connection Status. E-mail can not be delivered.');
end

end

