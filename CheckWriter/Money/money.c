//
//  money.c
//  test_M
//
//  Created by lip on 1/25/19.
//  Copyright © 2019 Andrew Lippman. All rights reserved.
//

#include "money.h"

static char *table[120] = {NULL, NULL};

int
initTable(){
    table[0] = "";
    table[1] = "One";
    table[2] = "Two";
    table[3] = "Three";
    table[4] = "Four";
    table[5] = "Five";
    table[6] = "Six";
    table[7] = "Seven";
    table[8] = "Eight";
    table[9] = "Nine";
    table[111] = "-one";
    table[112] = "-two";
    table[113] = "-three";
    table[114] = "-four";
    table[115] = "-five";
    table[116] = "-six";
    table[117] = "-seven";
    table[118] = "-eight";
    table[119] = "-nine";
    table[10] = "Ten";
    table[11] = "Eleven";
    table[12] = "Twelve";
    table[13] = "Thirteen";
    table[14] = "Fourteen";
    table[15] = "Fifteen";
    table[16] = "Sixteen";
    table[17] = "Seventeen";
    table[18] = "Eighteen";
    table[19] = "Nineteen";
    table[20] = "Twenty";
    table[30] = "Thirty";
    table[40] = "Forty";
    table[50] = "Fifty";
    table[60] = "Sixty";
    table[70] = "Seventy";
    table[80] = "Eighty";
    table[90] = "Ninety";
    return 0;
}

#define eq(a,b) (strcmp(a,b)==0)

/*  int amountTooBig(char *s) {     //  Not Used.  Fixed in sscanf below  10/13
    if (atoi(s)> 9000) {
        printf("*** amount too large: %s\n", s);
        return 1;
    }
    else {
        printf("*** amount OK: %s\n", s);
        return 0;
    }
    
}
 */
char *
numOnly(char *s) {
    static char    r[1024];
    int    i =0, j=0;
    
    
    while(s[i] != '\0') {
        if ( (s[i] >= '0' && s[i] <= '9' ) || s[i] == '.' ) {
            r[j] = s[i];
            j++;
        }
        i++;
    }
    r[j] = '\0';
    //    amountTooBig(r);
    
    return (r);
}

char *
money(char *s){         //  Fixed to cut off at 99K and too many pennies  10/13
    char m[2][1024];
    static char r[1024];
    int ones,tens,hundreds,phundreds,thousands,ten_thousands;
    int m0, m1;
    //    int init();
    
    if (!table[1]) initTable();
    
    *m[0] = *m[1] = *r = '\0';
    s = numOnly(s);
    sscanf(s,"%5[^.].%2s",m[0],m[1]);    //Fixed to abort pennies at 2 digits 10/13
    m0 = atoi(m[0]);
    m1 = atoi(m[1]);
    
    if (!m1) sprintf(r+strlen(r),"Exactly ");
    ones = m0 % 10;
    tens = (m0 - ones) % 100;
    hundreds = (m0 - (tens + ones)) % 1000;
    phundreds = hundreds / 100;
    thousands = ((m0 - (hundreds + tens + ones)) % 10000) / 1000;
    ten_thousands =
    ((m0 - ( thousands*1000 + hundreds + tens + ones)) % 100000) / 1000;
    
    /*    if (thousands == 1 && hundreds && !ten_thousands) {
     phundreds = 10 * thousands + phundreds;
     thousands = 0;
     }
     */
    if (ten_thousands && ten_thousands < 20) {
        ten_thousands += thousands;
        thousands = 0;
    }
    //   fprintf(stderr,"%d %d %d (%d) %d %d\n", ten_thousands, thousands,hundreds,phundreds,tens,ones);
    
    if (ten_thousands ) {
        sprintf(r+strlen(r),"%s ",table[ten_thousands]);
    }
    if (ten_thousands && !thousands) sprintf(r+strlen(r),"Thousand ");
    
    if (thousands) {
        sprintf(r+strlen(r),"%s Thousand",table[thousands]);
        if (hundreds && (tens || ones)) sprintf(r+strlen(r),", ");
        else if (tens || ones) sprintf(r+strlen(r)," and ");
        else if (hundreds || tens || ones) sprintf(r+strlen(r)," ");
    }
    if (hundreds) {
        sprintf(r+strlen(r),"%s Hundred",table[phundreds]);
        if (tens || ones) sprintf (r+strlen(r)," and ");
    }
    if (tens < 20) {
        char *tensd = table[tens+ones];
        sprintf(r+strlen(r),"%s dollars",tensd);
    }
    else if ( (tens >= 20) && (tens <= 90) && (ones > 0)){
        sprintf(r+strlen(r),"%s%s dollars",table[tens],table[110+ones]);
    }
    
    
    else sprintf(r+strlen(r),"%s dollars",table[tens]);
    if (m1) sprintf (r+strlen(r)," & %d cents",m1);
    return r;
}
