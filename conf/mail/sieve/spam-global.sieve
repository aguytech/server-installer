require ["fileinto"];

if header :contains "X-Spam-Flag" "YES" {
    fileinto "Junk";
    stop;
}

if header :is "X-Spam" "Yes" {
    fileinto "Junk";
    stop;
}
