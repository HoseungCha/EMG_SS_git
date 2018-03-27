#include "mex.h"
#include "matrix.h"
#include "stdio.h"
#include "stdlib.h"

typedef unsigned char byte;
union __int24 {struct _bytes {byte lolopart;
                             byte lopart;
                             byte hipart;
                             byte hihipart;
                             } BYTES;
                int value;
                };


void ReadBDFChannel(char *filename, int dataChannels, int datanSamples, int numberoftrials, int channelNumber, int sampleRate, int endOfFile, int sizeHeader, double *output)
{
FILE *file;
int res;
long dataPoint;
int i;
int j;
union __int24 temp;

    file = fopen(filename,"rb");
    for (i=0;i<numberoftrials;i++)
        {
        res=fseek(file,datanSamples*dataChannels*(i)*3+datanSamples*(channelNumber-1)*3+sizeHeader,0);
        for (j=0;j<datanSamples;j++)
            {
            fread(&temp.BYTES.lopart, 1, 1, file);
            fread(&temp.BYTES.hipart, 1, 1, file);
            fread(&temp.BYTES.hihipart, 1, 1, file);
            temp.BYTES.lolopart = 0;
            dataPoint = temp.value / 256;
            output[(i*datanSamples)+j] = dataPoint;
            }
        }
    fclose(file);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int dataChannels;
    int datanSamples;
    int channelNumber;
    int numberoftrials;
    int sampleRate;
    int endOfFile;
    int sizeHeader;
    char *filename;
    double *output;
    int buflen;
    int status;

    if (nrhs!=8)
        mexErrMsgTxt("Eight inputs required (Filename, Data Channels, Number of Samples, ChannelNumber, sampleRate, endOfFile, sizeHeader)");

    if (mxIsChar(prhs[0]) != 1)
        mexErrMsgTxt("First Input must be a string (Filename)");

    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
    filename = mxCalloc(buflen, sizeof(char));
    output = mxCalloc(buflen, sizeof(double));
    status = mxGetString(prhs[0], filename, buflen);
    dataChannels = mxGetScalar(prhs[1]);
    datanSamples = mxGetScalar(prhs[2]);
    numberoftrials = mxGetScalar(prhs[3]);
    channelNumber = mxGetScalar(prhs[4]);
    sampleRate = mxGetScalar(prhs[5]);
    endOfFile = mxGetScalar(prhs[6]);
    sizeHeader = mxGetScalar(prhs[7]);

    plhs[0] = mxCreateDoubleMatrix(numberoftrials*datanSamples,1, mxREAL);
    output = mxGetPr(plhs[0]);
    ReadBDFChannel(filename, dataChannels, datanSamples, numberoftrials, channelNumber, sampleRate,endOfFile,sizeHeader, output);
}
