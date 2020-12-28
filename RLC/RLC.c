//************************************************************************
// This is a version of the RLC subroutine written in C.
// It is not optimized, but it does function correctly.
//************************************************************************
// Input are pointers to the compressed data and uncompressed output buffer
// *comp points to the compressed data *dcomp points to output buffer
int rlc (unsigned char *comp, unsigned char *dcomp)
{
    unsigned char wh=32, bl=219; // define white and black
 // run = each input byte holds two runs
 // run[0] is the length of the first run
 // run[1] is the length of the second run
 // code = current compressed input byte
 // cur = current color to output
    unsigned char run[2], code, cur; // define variables
    unsigned pels_left, len, i; // pels_left = pels left in the current line
 // len = number of pels in the current run
    pels_left = 80; // there are 80 pels on a line
    cur = wh; // the first output color is white
    while( 1 ) // process all input runs
    {
        code = *comp; // code gets the current input byte
        comp++; // advance the input pointer
        if (code == 0) return(0); // a byte of 00h signals end of data
        // each input byte holds two run lengths
        run[0] = (unsigned char)(code >> 4); // run[0] = left 4 bits of input
        run[1] = (unsigned char)(code & 0x0f); // run[1] = right 4 bits of input
        for (i=0;i<2;i++) // loop for each of the 2 runs
        { // process a run
            if (pels_left == 0) // if at the end of a line then
            { // start a new line
                pels_left = 80; // 80 pels to fill on that new line
                cur = wh; // first color is white
            }
            if (run[i] == 15) len = pels_left; // a run of 15 means go to end of line
            else len = run[i]; // else we have a length 0-14
            while (len > 0) // output the run
            { //
                *dcomp = cur; // output a pel of the current color
                dcomp++; // advance the output pointer
                len--; // reduce # of pels to still to output
                pels_left--; // reduce # of pels avail on line
            }
            if (cur == wh) cur = bl; else cur = wh; // swap the output pel color
        } // end loop for 2 runs
    } // end loop to process all input runs
} // end the subroutine