

controls = [
    {
        control_names = [
            "AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS",
            
        ],
        organizational_unit_name = ["Nomura Wholesale"]
    }
]




    
new_maps = [
  {
    controls_for_each_org = {
      Nomura_Wholesale = {
        "ap-north-east-1" = ["arn:aws:controltower:ap-northeast-1::control/KNDLVQMVYRIW","arn:aws:controltower:ap-northeast-1::control/QBBKUFGDMMSM","arn:aws:controltower:ap-northeast-1::control/DDDZBLDXBNLI","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],
        "ap-south-east-1" = ["arn:aws:controltower:ap-southeast-1::control/ZLTPOVDCNCGM","arn:aws:controltower:ap-southeast-1::control/FDIWDCPRVBUD","arn:aws:controltower:ap-southeast-1::control/YDWHLDLLQYKQ","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],
        "eu-west-1" = ["arn:aws:controltower:eu-west-1::control/ESBANDFNAUPY","arn:aws:controltower:eu-west-1::control/EMUCXPDDRQRS","arn:aws:controltower:eu-west-1::control/DXEDENHXARDC","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],
        "us-east-1" = ["arn:aws:controltower:us-east-1::control/QYNBJXVUADDJ","arn:aws:controltower:us-east-1::control/XFNEYNNZPTGL","arn:aws:controltower:us-east-1::control/XGEAULNJZNVE","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],
        
        "eu-west-2" = ["YPAJJQFPQHZQ","XNMPIQQUPZZQ","VZAGIIIWANTB","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"]
      },
      Sandbox = {
        "ap-north-east_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "ap-south-east_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "us-east-1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-2" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"]
      },
      Security = {
        "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"]
      },
      Infrastructure = {
        "ap-north-east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "ap-south-east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER"]
      },
      Vendor = {
        "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER"]
      },
      POC = {
        "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"]
      },
      Non-Production = {
        "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER"]
      },
      Production = {
       "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER"]
      },
      UAT = {
        "ap-north-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "ap-south-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "us-east-1" = ["AWS-GR_RESTRICT_ROOT_USER"],
        "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER"]
      }
    },
    organizational_unit_name = ["Nomura_Wholesale","Sandbox","Security","Infrastructure","Vendor","POC","Non-Production", "Production", "UAT"]
  }
]



names_of_controls = {
        Nomura_Wholesale = {
            "ap_north_east_1" = ["CT.EC2.PV.1","CT.EC2.PV.2","CT.EC2.PV.3","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],

            "ap_south_east_1" = ["CT.EC2.PV.1","CT.EC2.PV.2","CT.EC2.PV.3","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],

            "eu_west_1" = ["CT.EC2.PV.1","CT.EC2.PV.2","CT.EC2.PV.3","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],

            "us_east_1" = ["CT.EC2.PV.1","CT.EC2.PV.2","CT.EC2.PV.3","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"],
            
            "eu-west-2" = ["CT.EC2.PV.1","CT.EC2.PV.2","CT.EC2.PV.3","AWS-GR_RESTRICT_ROOT_USER_ACCESS_KEYS"]
        },
        Sandbox = {
            "ap_north_east_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "ap_south_east_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu_west_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "us_east_1" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu-west-2" = ["AWS-GR_DISALLOW_VPN_CONNECTIONS"]
        },
        Security  = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_RESTRICT_S3_DELETE_WITHOUT_MFA","AWS-GR_DISALLOW_VPC_INTERNET_ACCESS","AWS-GR_DISALLOW_VPN_CONNECTIONS"]
        },
        Infrastructure = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER"]
        },
        Vendor = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER"]
        },
        POC = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "ap_south_east_1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu_west_1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "us_east_1" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"],
            "eu-west-2" = ["AWS-GR_RESTRICT_ROOT_USER","AWS-GR_DISALLOW_VPN_CONNECTIONS"]
        },
        Non_Production = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER"]
        } ,
        Production = {
           "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER"]
        },
        UAT = {
            "ap_north_east_1" = ["AWS-GR_RESTRICT_ROOT_USER"],
            "ap_south_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu_west_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "us_east_1" =  ["AWS-GR_RESTRICT_ROOT_USER"],
            "eu-west-2" =  ["AWS-GR_RESTRICT_ROOT_USER"]
        } 
    }
