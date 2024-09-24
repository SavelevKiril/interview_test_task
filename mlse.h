#ifndef MLSE_H
#define MLSE_H


class mlse
{
public:
    mlse();
    ~mlse();
    void run();
private:
    int channelLength;
    int blockLength;
};

#endif // MLSE_H
